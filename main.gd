extends Node


@export var server_scene: PackedScene
@export var server_control_panel_scene: PackedScene
@export var client_scene: PackedScene
@export var client_control_panel_scene: PackedScene

@onready var mode_selection_screen := %MultiplayerModeSelectionScreen as MultiplayerModeSelectionScreen


func _ready() -> void:
	print("Godot Multiplayer")
	if Utils.is_dedicated_server():
		print("dedicated_server=true")
	LaunchArgs.print_args()
	LaunchArgs.print_warnings()

	# Layout windows
	if LaunchArgs.has_window_placement:
		Utils.reposition_window(get_window(), LaunchArgs.window_placement)

	# Automatically select server or client mode
	var port: int = LaunchArgs.port if LaunchArgs.has_port else GameSettings.get_default_port()
	if LaunchArgs.server or Utils.is_dedicated_server():
		_select_server_mode(port, LaunchArgs.auto_start or Utils.is_dedicated_server())
	elif LaunchArgs.client:
		var address: String = LaunchArgs.address if LaunchArgs.has_address else "127.0.0.1"
		_select_client_mode(address, port, LaunchArgs.auto_connect)


func _select_server_mode(port: int, auto_start: bool) -> void:
	mode_selection_screen.queue_free()
	var server := server_scene.instantiate() as MultiplayerServer
	add_child(server)
	var control_panel := server_control_panel_scene.instantiate() as MultiplayerServerControlPanel
	control_panel.server = server
	add_child(control_panel)
	if port >= 0:
		control_panel.port = port
	if auto_start:
		server.start_server(port)


func _select_client_mode(address: String, port: int, auto_connect: bool) -> void:
	mode_selection_screen.queue_free()
	var client := client_scene.instantiate() as MultiplayerClient
	add_child(client)
	var control_panel := client_control_panel_scene.instantiate() as MultiplayerClientControlPanel
	control_panel.client = client
	add_child(control_panel)
	control_panel.address = address
	if port >= 0:
		control_panel.port = port
	if auto_connect:
		client.connect_to_server(address, port)


func _on_server_mode_selected(port: int) -> void:
	_select_server_mode(port, true)


func _on_client_mode_selected(address: String, port: int) -> void:
	_select_client_mode(address, port, true)
