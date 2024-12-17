extends Node

@export var server_root_scene: PackedScene
@export var client_root_scene: PackedScene
@export var world_scene: PackedScene

@onready var mode_selection_screen := %MultiplayerModeSelectionScreen as MultiplayerModeSelectionScreen


func _ready() -> void:
	print("Godot Multiplayer")
	print("is_dedicated_server=%s" % Utils.is_dedicated_server())
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
	var port: int = LaunchArgs.port if LaunchArgs.has_port else Utils.DEFAULT_SERVER_PORT_ID
	if (LaunchArgs.has_server_flag and LaunchArgs.server) or Utils.is_dedicated_server():
		_create_and_start_server(port)
	elif LaunchArgs.has_auto_connect_flag and LaunchArgs.auto_connect:
		_create_client_and_connect_to_server(address, port)


func _create_and_start_server(port: int) -> void:
	mode_selection_screen.queue_free()
	var server := server_root_scene.instantiate() as MultiplayerServerRoot
	add_child(server)
	var world := world_scene.instantiate() as Node
	server.add_child(world)
	server.start_server(port)


func _create_client_and_connect_to_server(address: String, port: int) -> void:
	mode_selection_screen.queue_free()
	var client := client_root_scene.instantiate() as MultiplayerClientRoot
	add_child(client)
	var world := world_scene.instantiate() as Node
	client.add_child(world)
	client.connect_to_server(address, port)


func _on_server_mode_selected(port: int) -> void:
	_create_and_start_server(port)


func _on_client_mode_selected(address: String, port: int) -> void:
	_create_client_and_connect_to_server(address, port)
