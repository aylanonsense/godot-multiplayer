class_name MultiplayerClientControlPanel
extends Control


@export var client: MultiplayerClient

var address: String:
	get(): return _address_input.text
	set(value): _address_input.text = value
var port: int:
	get(): return int(_port_input.text)
	set(value): _port_input.text = str(value)

@onready var _address_input := %AddressInput as LineEdit
@onready var _port_input := %PortInput as LineEdit
@onready var _connection_button := %ConnectionButton as Button
@onready var _send_number_button := %SendNumberButton as Button
@onready var _state_label := %StateLabel as Label
@onready var _log_view := %LogView as LogView


func _ready() -> void:
	_port_input.placeholder_text = str(GameSettings.get_default_port())
	client.something_happened.connect(_on_client_something_happened)


func _process(_delta: float) -> void:
	_state_label.text = "" if not client._peer else Utils.enet_peer_state_string(client._peer.get_state())
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
	_connection_button.disabled = not can_connect and not can_disconnect
	if can_connect:
		_connection_button.text = "Connect"
	elif can_disconnect:
		_connection_button.text = "Disconnect"
	else:
		_connection_button.text = "Disconnect" if is_connected else "Connect"
	_send_number_button.disabled = not can_send


func _on_client_something_happened(text: String) -> void:
	_log_view.add_log_line(text)


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
		var address := _address_input.text if not _address_input.text.is_empty() else _address_input.placeholder_text
		var port := int(_port_input.text if not _port_input.text.is_empty() else _port_input.placeholder_text)
		client.connect_to_server(address, port)
	elif can_disconnect:
		client.disconnect_from_server()


func _on_send_number_button_pressed() -> void:
	client.send_number(randi_range(0, 255))
