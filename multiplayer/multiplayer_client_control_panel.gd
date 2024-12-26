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
@onready var connect_button := %ConnectButton as Button
@onready var disconnect_button := %DisconnectButton as Button
@onready var state_label := %StateLabel as Label
@onready var number_inputs: Array[SpinBox] = [%NumberInput1, %NumberInput2]
@onready var send_button := %SendButton as Button
@onready var logs := %LogView as LogView


func _ready() -> void:
	port_input.placeholder_text = str(GameSettings.get_default_port())
	for number_input in number_inputs:
		number_input.value = randi_range(0, 254)
	_refresh_ui()
	client.started_connecting.connect(_on_client_started_connecting)
	client.connected.connect(_on_client_connected)
	client.disconnected.connect(_on_client_disconnected)
	client.received_packet.connect(_on_client_received_packet)


func _print_and_log(text: String) -> void:
	print(text)
	logs.add_log_line(text)


func _refresh_ui() -> void:
	address_input.editable = client.state == MultiplayerClient.State.DISCONNECTED
	port_input.editable = client.state == MultiplayerClient.State.DISCONNECTED
	connect_button.disabled = client.state != MultiplayerClient.State.DISCONNECTED
	disconnect_button.disabled = client.state == MultiplayerClient.State.DISCONNECTED
	send_button.disabled = client.state != MultiplayerClient.State.CONNECTED
	match client.state:
		MultiplayerClient.State.DISCONNECTED: state_label.text = "Disconnected"
		MultiplayerClient.State.CONNECTING: state_label.text = "Connecting"
		MultiplayerClient.State.CONNECTED: state_label.text = "Connected"


func _on_client_started_connecting() -> void:
	_refresh_ui()
	_print_and_log("Connecting to address %s port %d.." % [client.address, client.port])


func _on_client_connected() -> void:
	_refresh_ui()
	_print_and_log("Connected")


func _on_client_disconnected() -> void:
	_refresh_ui()
	_print_and_log("Disconnected")


func _on_client_received_packet(packet: PackedByteArray) -> void:
	_print_and_log("Received packet %s" % str(packet))


func _on_connect_button_pressed() -> void:
	var address := address_input.text if not address_input.text.is_empty() else address_input.placeholder_text
	var port := int(port_input.text if not port_input.text.is_empty() else port_input.placeholder_text)
	client.connect_to_server(address, port)


func _on_disconnect_button_pressed() -> void:
	client.disconnect_from_server()


func _on_send_button_pressed() -> void:
	var packet := PackedByteArray()
	packet.resize(number_inputs.size())
	for i in range(number_inputs.size()):
		packet.encode_u8(i, int(number_inputs[i].value))
	_print_and_log("Sending packet %s" % str(packet))
	client.send_packet(packet)
