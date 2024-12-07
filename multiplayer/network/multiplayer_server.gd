class_name MultiplayerServer
extends Node


signal server_started()
signal server_failed_to_start()
signal server_stopped()
signal client_connected(id: int)
signal client_disconnected(id: int)

@export var port := 12345
@export var max_clients := 8
@export var compression: ENetConnection.CompressionMode = ENetConnection.CompressionMode.COMPRESS_NONE

var started := false
var multiplayer_api: MultiplayerAPI


func _ready() -> void:
	multiplayer_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(multiplayer_api, get_path())
	multiplayer_api.peer_connected.connect(_on_peer_connected)
	multiplayer_api.peer_disconnected.connect(_on_peer_disconnected)


func start_server() -> void:
	if started:
		return
	multiplayer_api.multiplayer_peer = null
	started = true
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port, max_clients)
	if result != OK:
		started = false
		server_failed_to_start.emit()
		return
	peer.host.compress(compression)
	multiplayer_api.multiplayer_peer = peer
	server_started.emit()


func stop_server() -> void:
	if not started:
		return
	started = false
	multiplayer_api.multiplayer_peer = null
	server_stopped.emit()


func _on_peer_connected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_disconnected.emit(id)
