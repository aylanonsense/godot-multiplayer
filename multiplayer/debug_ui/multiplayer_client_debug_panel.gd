class_name MultiplayerClientDebugPanel
extends Control


@onready var connect_button := %ConnectButton as Button
@onready var disconnect_button := %DisconnectButton as Button
@onready var status_label := %StatusLabel as Label
@onready var logs := %LogView as LogView

@export var client: MultiplayerClient:
	set(value):
		if is_node_ready():
			_try_unbinding_from_client()
		client = value
		if is_node_ready():
			_try_binding_to_client()
			logs.clear_log_lines()
			_refresh_ui()


func _ready() -> void:
	_try_binding_to_client()
	_refresh_ui()


func _try_binding_to_client() -> void:
	if not client:
		return
	client.started_connecting_to_server.connect(_on_started_connecting_to_server)
	client.connected_to_server.connect(_on_connected_to_server)
	client.connection_failed.connect(_on_connection_failed)
	client.disconnected_from_server.connect(_on_disconnected_from_server)
	client.client_connected.connect(_on_client_connected)
	client.client_disconnected.connect(_on_client_disconnected)


func _try_unbinding_from_client() -> void:
	if not client:
		return
	client.started_connecting_to_server.disconnect(_on_started_connecting_to_server)
	client.connected_to_server.disconnect(_on_connected_to_server)
	client.connection_failed.disconnect(_on_connection_failed)
	client.disconnected_from_server.disconnect(_on_disconnected_from_server)
	client.client_connected.disconnect(_on_client_connected)
	client.client_disconnected.disconnect(_on_client_disconnected)


func _refresh_ui() -> void:
	if not client:
		connect_button.disabled = true
		disconnect_button.disabled = true
		status_label.text = ""
		return
	connect_button.disabled = client.status != MultiplayerClient.Status.DISCONNECTED
	disconnect_button.disabled = client.status != MultiplayerClient.Status.CONNECTED
	match client.status:
		MultiplayerClient.Status.DISCONNECTED: status_label.text = "Client disconnected"
		MultiplayerClient.Status.CONNECTING: status_label.text = "Client connecting.."
		MultiplayerClient.Status.CONNECTED: status_label.text = "Client connected as %d" % client.get_client_id()


func _on_connect_button_pressed() -> void:
	if not client:
		return
	client.connect_to_server()


func _on_disconnect_button_pressed() -> void:
	if not client:
		return
	client.disconnect_from_server()


func _on_started_connecting_to_server() -> void:
	logs.add_log_line("Connecting...")
	_refresh_ui()


func _on_connected_to_server() -> void:
	logs.add_log_line("Connected to server as %d" % client.get_client_id())
	_refresh_ui()


func _on_connection_failed() -> void:
	logs.add_log_line("Connection failed")
	_refresh_ui()


func _on_disconnected_from_server() -> void:
	logs.add_log_line("Disconnected from server")
	_refresh_ui()


func _on_client_connected(id: int) -> void:
	logs.add_log_line("Client %d connected" % id)
	_refresh_ui()


func _on_client_disconnected(id: int) -> void:
	logs.add_log_line("Client %d disconnected" % id)
	_refresh_ui()
