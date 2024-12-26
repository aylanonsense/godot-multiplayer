class_name MultiplayerClient
extends Node


signal started_connecting()
signal connected()
signal disconnected()
signal received_packet(packet: PackedByteArray)

enum State {
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2
}

var state := State.DISCONNECTED
var address := ""
var port := -1

var _connection: ENetConnection
var _peer: ENetPacketPeer


func _process(_delta: float) -> void:
	while _connection:
		var event := _connection.service()
		if not event:
			break
		var event_type := event[0] as ENetConnection.EventType
		match event_type:
			ENetConnection.EventType.EVENT_ERROR:
				disconnect_from_server()
				break
			ENetConnection.EventType.EVENT_NONE:
				break
			ENetConnection.EventType.EVENT_CONNECT:
				if state != State.CONNECTED:
					state = State.CONNECTED
					connected.emit()
			ENetConnection.EventType.EVENT_DISCONNECT:
				_destroy_peer_and_connection()
				if state != State.DISCONNECTED:
					state = State.DISCONNECTED
					disconnected.emit()
			ENetConnection.EventType.EVENT_RECEIVE:
				var peer := event[1] as ENetPacketPeer
				var packet := peer.get_packet()
				received_packet.emit(packet)


func connect_to_server(address: String, port: int) -> Error:
	disconnect_from_server()
	self.address = address
	self.port = port
	state = State.CONNECTING
	started_connecting.emit()
	_connection = ENetConnection.new()
	var result := _connection.create_host(1)
	if result != OK:
		disconnect_from_server()
		return result
	_peer = _connection.connect_to_host(address, port)
	return result


func disconnect_from_server() -> void:
	if state == State.DISCONNECTED:
		return
	if _peer:
		_peer.peer_disconnect_now()
	_destroy_peer_and_connection()
	state = State.DISCONNECTED
	disconnected.emit()


func send_packet(packet: PackedByteArray) -> void:
	if _peer:
		_peer.send(0, packet, 0)


func _destroy_peer_and_connection() -> void:
	_peer = null
	if _connection:
		_connection.destroy()
	_connection = null
