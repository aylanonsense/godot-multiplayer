class_name MultiplayerClientControlPanel
extends Control


@export var client: MultiplayerClient

var address: String:
	get(): return address_input.text
	set(value): address_input.text = value
var port: int:
	get(): return int(port_input.text)
	set(value): port_input.text = str(value)

@onready var address_input := %AddressInput as LineEdit
@onready var port_input := %PortInput as LineEdit
@onready var connection_button := %ConnectionButton as Button
@onready var send_number_button := %SendNumberButton as Button
@onready var state_label := %StateLabel as Label
@onready var log_view := %LogView as LogView


func _ready() -> void:
	port_input.placeholder_text = str(GameSettings.get_default_port())
	client.something_happened.connect(_on_client_something_happened)


func _process(_delta: float) -> void:
	state_label.text = "" if not client._peer else Utils.enet_peer_state_string(client._peer.get_state())
	var is_connected := false
	var can_connect := false
	var can_disconnect := false
	var can_send := false
	if not client._peer:
		can_connect = true
	else:
		match client._peer.get_state():
			ENetPacketPeer.PeerState.STATE_DISCONNECTED:
				can_connect = true
			ENetPacketPeer.PeerState.STATE_CONNECTING:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_CONNECT:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTION_PENDING:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTION_SUCCEEDED:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTED:
				is_connected = true
				can_disconnect = true
				can_send = true
			ENetPacketPeer.PeerState.STATE_DISCONNECT_LATER:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_DISCONNECTING:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_DISCONNECT:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_ZOMBIE:
				can_connect = true
	if is_connected:
		address = client._peer.get_remote_address()
		port = client._peer.get_remote_port()
	connection_button.disabled = not can_connect and not can_disconnect
	if can_connect:
		connection_button.text = "Connect"
	elif can_disconnect:
		connection_button.text = "Disconnect"
	else:
		connection_button.text = "Disconnect" if is_connected else "Connect"
	send_number_button.disabled = not can_send
	address_input.editable = can_connect
	port_input.editable = can_connect


func _on_client_something_happened(text: String) -> void:
	log_view.add_log_line(text)
	print(text)


func _on_connection_button_pressed() -> void:
	var is_connected := false
	var can_connect := false
	var can_disconnect := false
	if not client._peer:
		can_connect = true
	else:
		match client._peer.get_state():
			ENetPacketPeer.PeerState.STATE_DISCONNECTED:
				can_connect = true
			ENetPacketPeer.PeerState.STATE_CONNECTING:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_CONNECT:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTION_PENDING:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTION_SUCCEEDED:
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_CONNECTED:
				is_connected = true
				can_disconnect = true
			ENetPacketPeer.PeerState.STATE_DISCONNECT_LATER:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_DISCONNECTING:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_DISCONNECT:
				is_connected = true
			ENetPacketPeer.PeerState.STATE_ZOMBIE:
				can_connect = true
	if can_connect:
		var address := address_input.text if not address_input.text.is_empty() else address_input.placeholder_text
		var port := int(port_input.text if not port_input.text.is_empty() else port_input.placeholder_text)
		client.connect_to_server(address, port)
	elif can_disconnect:
		client.disconnect_from_server()


func _on_send_number_button_pressed() -> void:
	client.send_number(randi_range(0, 254))
