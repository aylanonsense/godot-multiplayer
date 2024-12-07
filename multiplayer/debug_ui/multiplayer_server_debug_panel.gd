class_name MultiplayerServerDebugPanel
extends Control


@onready var start_button := %StartButton as Button
@onready var stop_button := %StopButton as Button
@onready var status_label := %StatusLabel as Label
@onready var logs := %LogView as LogView

@export var server: MultiplayerServer:
	set(value):
		if is_node_ready():
			_try_unbinding_from_server()
		server = value
		if is_node_ready():
			_try_binding_to_server()
			logs.clear_log_lines()
			_refresh_ui()


func _ready() -> void:
	_try_binding_to_server()
	_refresh_ui()


func _try_binding_to_server() -> void:
	if not server:
		return
	server.server_started.connect(_on_server_started)
	server.server_failed_to_start.connect(_on_server_failed_to_start)
	server.server_stopped.connect(_on_server_stopped)
	server.client_connected.connect(_on_client_connected)
	server.client_disconnected.connect(_on_client_disconnected)


func _try_unbinding_from_server() -> void:
	if not server:
		return
	server.server_started.disconnect(_on_server_started)
	server.server_failed_to_start.disconnect(_on_server_failed_to_start)
	server.server_stopped.disconnect(_on_server_stopped)
	server.client_connected.disconnect(_on_client_connected)
	server.client_disconnected.disconnect(_on_client_disconnected)


func _refresh_ui() -> void:
	if not server:
		start_button.disabled = true
		stop_button.disabled = true
		status_label.text = ""
		return
	start_button.disabled = server.started
	stop_button.disabled = not server.started
	status_label.text = "Server started" if server.started else "Server stopped"


func _on_start_button_pressed() -> void:
	if not server:
		return
	server.start_server()


func _on_stop_button_pressed() -> void:
	if not server:
		return
	server.stop_server()


func _on_server_started() -> void:
	logs.add_log_line("Started")
	_refresh_ui()


func _on_server_failed_to_start() -> void:
	logs.add_log_line("Server failed to start")
	_refresh_ui()


func _on_server_stopped() -> void:
	logs.add_log_line("Stopped")
	_refresh_ui()


func _on_client_connected(id: int) -> void:
	logs.add_log_line("Client %d connected" % id)
	_refresh_ui()


func _on_client_disconnected(id: int) -> void:
	logs.add_log_line("Client %d disconnected" % id)
	_refresh_ui()
