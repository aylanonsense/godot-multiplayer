extends Control


const SERVER_ID := 1

@export var address := "127.0.0.1"
@export var port := 12345
@export var max_clients := 8
@export var compression: ENetConnection.CompressionMode = ENetConnection.CompressionMode.COMPRESS_NONE

@onready var host_button := %Host as Button
@onready var join_button := %Join as Button
@onready var disconnect_button := %Disconnect as Button
@onready var log_scroll_container := %LogScroll as ScrollContainer
@onready var log_template := %LogTemplate as Label


func _ready() -> void:
	log_template.visible = false
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	log_scroll_container.get_v_scroll_bar().connect("changed", _scroll_logs_to_bottom)
	host_button.disabled = false
	join_button.disabled = false
	disconnect_button.disabled = true
	var args := Utils.get_parsed_cmdline_args()
	if args.has("server") and args.server:
		_start_server()
	if args.has("connect") and args.connect:
		_connect_to_server()


func _connected_to_server() -> void:
	_log("Connected to server as peer %d" % multiplayer.get_unique_id())
	host_button.disabled = true
	join_button.disabled = true
	disconnect_button.disabled = false


func _connection_failed() -> void:
	_log("Connection to server failed")
	host_button.disabled = false
	join_button.disabled = false
	disconnect_button.disabled = true


func _server_disconnected() -> void:
	_log("Server disconnected")
	host_button.disabled = false
	join_button.disabled = false
	disconnect_button.disabled = true


func _peer_connected(id: int) -> void:
	_log("%s connected" % ("Server" if id == SERVER_ID else "Peer %d" % id))


func _peer_disconnected(id: int) -> void:
	_log("%s disconnected" % ("Server" if id == SERVER_ID else "Peer %d" % id))


func _scroll_logs_to_bottom():
	log_scroll_container.scroll_vertical = ceil(log_scroll_container.get_v_scroll_bar().max_value)


func _on_host_button_down() -> void:
	_start_server()


func _on_join_button_down() -> void:
	_connect_to_server()


func _on_disconnect_button_down() -> void:
	if multiplayer.is_server():
		_stop_server()
	else:
		_disconnect_from_server()


func _start_server() -> void:
	multiplayer.multiplayer_peer = null
	_log("Starting server...")
	host_button.disabled = true
	join_button.disabled = true
	disconnect_button.disabled = true
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port, max_clients)
	if result != OK:
		match result:
			ERR_ALREADY_IN_USE:
				_log("Connection already in use")
			ERR_CANT_CREATE:
				_log("Can't create server")
			_:
				_log("Unknown issue creating server")
		host_button.disabled = false
		join_button.disabled = false
		disconnect_button.disabled = true
		return
	peer.host.compress(compression)
	multiplayer.multiplayer_peer = peer
	_log("Server started")
	host_button.disabled = true
	join_button.disabled = true
	disconnect_button.disabled = false


func _connect_to_server() -> void:
	multiplayer.multiplayer_peer = null
	_log("Connecting to server...")
	host_button.disabled = true
	join_button.disabled = true
	disconnect_button.disabled = true
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, port)
	if result != OK:
		match result:
			ERR_ALREADY_IN_USE:
				_log("Connection already in use")
			ERR_CANT_CREATE:
				_log("Can't create client")
			_:
				_log("Unknown issue creating client")
		host_button.disabled = false
		join_button.disabled = false
		disconnect_button.disabled = false
		return
	peer.host.compress(compression)
	multiplayer.multiplayer_peer = peer


func _stop_server() -> void:
	multiplayer.multiplayer_peer = null
	_log("Server stopped")
	host_button.disabled = false
	join_button.disabled = false
	disconnect_button.disabled = true


func _disconnect_from_server() -> void:
	multiplayer.multiplayer_peer = null
	_log("Disconnected from server")
	host_button.disabled = false
	join_button.disabled = false
	disconnect_button.disabled = true


func _log(text: String) -> void:
	var log_label := log_template.duplicate() as Label
	log_label.text = text
	log_label.visible = true
	log_template.get_parent().add_child(log_label)
