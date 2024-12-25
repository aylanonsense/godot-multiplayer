class_name MultiplayerClient
extends Node


signal something_happened(text: String)

var _connection: ENetConnection
var _peer: ENetPacketPeer


func connect_to_server(address: String, port: int) -> Error:
	_connection = ENetConnection.new()
	var result := _connection.create_host(1)
	if result != OK:
		if _connection:
			_connection.destroy()
		_connection = null
		return result
	_peer = _connection.connect_to_host(address, port)
	return result


func disconnect_from_server() -> void:
	_peer.peer_disconnect()


func send_number(number: int) -> void:
	something_happened.emit("Client sending %d" % number)
	var packet := PackedByteArray()
	packet.resize(1)
	packet.encode_u8(0, number)
	_peer.send(0, packet, 0)


func _process(_delta: float) -> void:
	while _connection:
		var event := _connection.service()
		if not event:
			break
		var event_type: ENetConnection.EventType = event[0]
		if event_type != ENetConnection.EventType.EVENT_NONE:
			something_happened.emit("Client received %s" % Utils.enet_event_type_string(event_type))
		match event_type:
			ENetConnection.EventType.EVENT_ERROR:
				break
			ENetConnection.EventType.EVENT_NONE:
				break
			#ENetConnection.EventType.EVENT_CONNECT:
				#break
			#ENetConnection.EventType.EVENT_DISCONNECT:
				#break
			ENetConnection.EventType.EVENT_RECEIVE:
				var peer: ENetPacketPeer = event[1]
				var packet := peer.get_packet()
				var channel: int = event[3]
				var number := packet.decode_u8(0)
				something_happened.emit("Client received number %d" % number)
