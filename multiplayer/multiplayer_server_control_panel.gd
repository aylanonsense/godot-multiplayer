class_name MultiplayerServerControlPanel
extends Control


@export var server: MultiplayerServer

var port: int:
	get(): return int(port_input.text)
	set(value): port_input.text = str(value)

@onready var port_input := %PortInput as LineEdit
@onready var server_button := %ServerButton as Button
@onready var num_peers_label := %NumPeersLabel as Label
@onready var log_view := %LogView as LogView


func _ready() -> void:
	port_input.placeholder_text = str(GameSettings.get_default_port())
	server.something_happened.connect(_on_server_something_happened)


func _process(_delta: float) -> void:
	if server._connection:
		port_input.text = str(server._connection.get_local_port())
		var num_peers := server._connection.get_peers().size()
		num_peers_label.text = "%d %s" % [num_peers, "peer" if num_peers == 1 else "peers"]
	else:
		num_peers_label.text = "Stopped"
	if server._connection:
		server_button.text = "Stop server"
	else:
		server_button.text = "Start server"
	port_input.editable = not server._connection


func _on_server_something_happened(text: String) -> void:
	log_view.add_log_line(text)
	print(text)


func _on_server_button_pressed() -> void:
	if server._connection:
		server.stop_server()
	else:
		server.start_server(int(port_input.text))
