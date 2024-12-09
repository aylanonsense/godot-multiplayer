class_name MultiplayerModeSelectionScreen
extends Control


signal server_mode_selected(port: int)
signal client_mode_selected(address: String, port: int)

@onready var server_port_input := %ServerPortInput as LineEdit
@onready var client_address_input := %ClientAddressInput as LineEdit
@onready var client_port_input := %ClientPortInput as LineEdit


func _on_host_server_button_pressed() -> void:
	var port := int(server_port_input.text if not server_port_input.text.is_empty() else server_port_input.placeholder_text)
	server_mode_selected.emit(port)


func _on_client_connect_button_pressed() -> void:
	var address := client_address_input.text if not client_address_input.text.is_empty() else client_address_input.placeholder_text
	var port := int(client_port_input.text if not client_port_input.text.is_empty() else client_port_input.placeholder_text)
	client_mode_selected.emit(address, port)
