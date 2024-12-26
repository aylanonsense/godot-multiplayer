class_name MultiplayerServerControlPanel
extends Control


@export var server: MultiplayerServer

var port: int:
	get(): return int(port_input.text)
	set(value): port_input.text = str(value)

@onready var port_input := %PortInput as LineEdit
@onready var start_button := %StartButton as Button
@onready var stop_button := %StopButton as Button
@onready var state_label := %StateLabel as Label
@onready var logs := %LogView as LogView


func _ready() -> void:
	port_input.placeholder_text = str(GameSettings.get_default_port())
	_refresh_ui()
	server.started.connect(_on_server_started)
	server.stopped.connect(_on_server_stopped)
	server.client_connected.connect(_on_server_client_connected)
	server.client_disconnected.connect(_on_server_client_disconnected)
	server.received_packet.connect(_on_server_received_packet)


func _print_and_log(text: String) -> void:
	print(text)
	logs.add_log_line(text)


func _refresh_ui() -> void:
	port_input.editable = not server.is_started
	start_button.disabled = server.is_started
	stop_button.disabled = not server.is_started
	state_label.text = "Stopped" if not server.is_started else "%d %s" % [server.clients.size(), "client" if server.clients.size() == 1 else "clients"]


func _on_server_started() -> void:
	_refresh_ui()
	_print_and_log("Started on port %d..." % server.port)


func _on_server_stopped() -> void:
	_refresh_ui()
	_print_and_log("Stopped")


func _on_server_client_connected(client: MultiplayerClientIdentity) -> void:
	_refresh_ui()
	_print_and_log("Client %d connected" % client.id)


func _on_server_client_disconnected(client: MultiplayerClientIdentity) -> void:
	_refresh_ui()
	_print_and_log("Client %d disconnected" % client.id)


func _on_server_received_packet(packet: PackedByteArray, client: MultiplayerClientIdentity) -> void:
	_print_and_log("Received packet %s from client %d" % [str(packet), client.id])
	var response_packet := PackedByteArray()
	response_packet.resize(packet.size())
	for i in range(packet.size()):
		response_packet.encode_u8(i, packet.decode_u8(i) + 1)
	server.broadcast_packet(response_packet)


func _on_start_button_pressed() -> void:
	var port := int(port_input.text if not port_input.text.is_empty() else port_input.placeholder_text)
	server.start_server(port)


func _on_stop_button_pressed() -> void:
	server.stop_server()
