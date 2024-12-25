extends Node


@export var server_scene: PackedScene
@export var server_control_panel_scene: PackedScene
@export var client_scene: PackedScene
@export var client_control_panel_scene: PackedScene

@onready var mode_selection_screen := %MultiplayerModeSelectionScreen as MultiplayerModeSelectionScreen


func _ready() -> void:
	print("Godot Multiplayer")
	print("dedicated_server=%s" % OS.has_feature("dedicated_server"))
	LaunchArgs.print_args()
	LaunchArgs.print_warnings()

	# Layout windows
	if LaunchArgs.has_window_placement:
		var window := get_window()
		var screen_rect := DisplayServer.screen_get_usable_rect(window.current_screen)
		var top_gap := 150
		var gap := 75
		var half_gap := gap / 2
		var position := screen_rect.position + Vector2i(gap, top_gap)
		var width := screen_rect.size.x - 2 * gap
		var half_width := width / 2
		var height := screen_rect.size.y - top_gap - gap
		var half_height := height / 2
		match LaunchArgs.window_placement:
			"full":
				window.position = position
				window.size = Vector2i(width, height)
			"left":
				window.position = position
				window.size = Vector2i(half_width - half_gap, height)
			"right":
				window.position = position + Vector2i(half_width + half_gap, 0)
				window.size = Vector2i(half_width - half_gap, height)
			"upper-left":
				window.position = position
				window.size = Vector2i(half_width - half_gap, half_height - half_gap)
			"lower-left":
				window.position = position + Vector2i(0, half_height + half_gap)
				window.size = Vector2i(half_width - half_gap, half_height - half_gap)
			"upper-right":
				window.position = position + Vector2i(half_width + half_gap, 0)
				window.size = Vector2i(half_width - half_gap, half_height - half_gap)
			"lower-right":
				window.position = position + Vector2i(half_width + half_gap, half_height + half_gap)
				window.size = Vector2i(half_width - half_gap, half_height - half_gap)

	# Automatically start server or client
	var address: String = LaunchArgs.address if LaunchArgs.has_address else "127.0.0.1"
	var port: int = LaunchArgs.port if LaunchArgs.has_port else GameSettings.get_default_port()
	if LaunchArgs.server or OS.has_feature("dedicated_server"):
		_switch_to_server_mode(port, LaunchArgs.auto_start or OS.has_feature("dedicated_server"))
	elif LaunchArgs.client:
		_switch_to_client_mode(address, port, LaunchArgs.auto_connect)


func _switch_to_server_mode(port: int, auto_start: bool) -> void:
	print("Switching to server mode")
	mode_selection_screen.queue_free()
	var server := server_scene.instantiate() as MultiplayerServer
	add_child(server)
	var control_panel := server_control_panel_scene.instantiate() as MultiplayerServerControlPanel
	control_panel.server = server
	add_child(control_panel)
	if auto_start:
		server.start_server(port)


func _switch_to_client_mode(address: String, port: int, auto_connect: bool) -> void:
	print("Switching to client mode")
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
	_switch_to_server_mode(port, true)


func _on_client_mode_selected(address: String, port: int) -> void:
	_switch_to_client_mode(address, port, true)
