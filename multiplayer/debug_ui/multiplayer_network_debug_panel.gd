class_name MultiplayerNetworkDebugPanel
extends Control


@onready var add_server_button := %AddServerButton as Button
@onready var add_client_button := %AddClientButton as Button
@onready var panel_grid := %MultiplayerDebugPanelGrid as MultiplayerDebugPanelGrid

@export var network: MultiplayerNetwork:
	set(value):
		if is_node_ready():
			_try_unbinding_from_network()
		network = value
		if is_node_ready():
			_try_binding_to_network()
			_try_creating_panels_for_network()
			_refresh_ui()


func _ready() -> void:
	_try_binding_to_network()
	_try_creating_panels_for_network()
	_refresh_ui()


func _try_binding_to_network() -> void:
	if not network:
		return
	network.server_created.connect(_on_server_created)
	network.client_created.connect(_on_client_created)


func _try_unbinding_from_network() -> void:
	if not network:
		return
	network.server_created.disconnect(_on_server_created)
	network.client_created.disconnect(_on_client_created)


func _try_creating_panels_for_network() -> void:
	panel_grid.remove_all_panels()
	if network:
		for server in network.servers:
			panel_grid.create_panel_for_server(server)
		for client in network.clients:
			panel_grid.create_panel_for_client(client)


func _refresh_ui() -> void:
	add_server_button.disabled = not network
	add_client_button.disabled = not network


func _on_add_server_button_pressed() -> void:
	if not network:
		return
	network.create_server()


func _on_add_client_button_pressed() -> void:
	if not network:
		return
	network.create_client()


func _on_server_created(server: MultiplayerServer) -> void:
	panel_grid.create_panel_for_server(server)


func _on_client_created(client: MultiplayerClient) -> void:
	panel_grid.create_panel_for_client(client)
