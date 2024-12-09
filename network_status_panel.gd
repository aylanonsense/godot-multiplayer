class_name NetworkStatusPanel
extends Control


@onready var status_label := %StatusLabel as Label
@onready var logs := %LogView as LogView


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_refresh_ui()


func _process(_delta: float) -> void:
	_refresh_ui()


func _refresh_ui() -> void:
	if multiplayer.multiplayer_peer:
		var status := multiplayer.multiplayer_peer.get_connection_status()
		match status:
			MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED:
				status_label.text = ""
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING:
				status_label.text = "Server (starting...)" if multiplayer.is_server() else "Client (connecting...)"
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
				status_label.text = "Server" if multiplayer.is_server() else ("Client %d" % multiplayer.get_unique_id())
	else:
		status_label.text = ""
#This MultiplayerPeer is connected.
	#if multiplayer.is_server():
		#status_label.text = "Server"	
	#else:
		#status_label.text = "Client %d" % multiplayer.get_unique_id()
	#status_label.text = ""


func _on_connected_to_server() -> void:
	logs.add_log_line("Connected to server as %d" % multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	logs.add_log_line("_on_connection_failed")


func _on_server_disconnected() -> void:
	logs.add_log_line("Disconnected from server")


func _on_peer_connected(id: int) -> void:
	logs.add_log_line("Peer %d connected" % id)


func _on_peer_disconnected(id: int) -> void:
	logs.add_log_line("Peer %d disconnected" % id)
