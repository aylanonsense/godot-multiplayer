class_name MultiplayerDebugPanelGrid
extends Control


@onready var server_template := %ServerTemplate as MultiplayerServerDebugPanel
@onready var client_template := %ClientTemplate as MultiplayerClientDebugPanel
@onready var grid_container := server_template.get_parent() as GridContainer


func _ready() -> void:
	server_template.visible = false
	client_template.visible = false


func create_panel_for_server(server: MultiplayerServer) -> MultiplayerServerDebugPanel:
	var panel := server_template.duplicate() as MultiplayerServerDebugPanel
	panel.name = server.name
	panel.server = server
	panel.visible = true
	grid_container.add_child(panel)
	_refresh_ui()
	return panel


func create_panel_for_client(client: MultiplayerClient) -> MultiplayerClientDebugPanel:
	var panel := client_template.duplicate() as MultiplayerClientDebugPanel
	panel.name = client.name
	panel.client = client
	panel.visible = true
	grid_container.add_child(panel)
	_refresh_ui()
	return panel


func remove_all_panels() -> void:
	for panel in grid_container.get_children():
		if panel != server_template && panel != client_template:
			grid_container.remove_child(panel)
			panel.queue_free()


func _refresh_ui() -> void:
	var num_panels := grid_container.get_child_count() - 2
	if num_panels < 2:
		grid_container.columns = 1
	elif num_panels > 6:
		grid_container.columns = 4
	elif num_panels == 3 or num_panels == 5 or num_panels == 6:
		grid_container.columns = 3
	else:
		grid_container.columns = 2
