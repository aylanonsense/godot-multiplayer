class_name MultiplayerServer
extends Node


signal started()
signal stopped()
signal client_connected(client: MultiplayerClientIdentity)
signal client_disconnected(client: MultiplayerClientIdentity)
signal received_packet(packet: PackedByteArray, client: MultiplayerClientIdentity)

var is_started := false
var port := -1
var clients: Array[MultiplayerClientIdentity] = []

var _connection: ENetConnection
var _client_lookup := {}
var _next_client_id := 1


func _process(_delta: float) -> void:
	while _connection:
		var event := _connection.service()
		if not event:
			break
		var event_type := event[0] as ENetConnection.EventType
		match event_type:
			ENetConnection.EventType.EVENT_ERROR:
				stop_server()
				break
			ENetConnection.EventType.EVENT_NONE:
				break
			ENetConnection.EventType.EVENT_CONNECT:
				var peer := event[1] as ENetPacketPeer
				var client := MultiplayerClientIdentity.new(_next_client_id, peer)
				_next_client_id += 1
				clients.append(client)
				_client_lookup[peer] = client
				client_connected.emit(client)
			ENetConnection.EventType.EVENT_DISCONNECT:
				var peer := event[1] as ENetPacketPeer
				var client := _client_lookup[peer] as MultiplayerClientIdentity
				clients.erase(client)
				_client_lookup.erase(peer)
				client_disconnected.emit(client)
			ENetConnection.EventType.EVENT_RECEIVE:
				var peer := event[1] as ENetPacketPeer
				var client := _client_lookup[peer] as MultiplayerClientIdentity
				var packet := peer.get_packet()
				received_packet.emit(packet, client)



func start_server(port: int) -> Error:
	stop_server()
	self.port = port
	_connection = ENetConnection.new()
	var result := _connection.create_host_bound("0.0.0.0", port)
	if result != OK:
		stop_server()
		return result
	is_started = true
	started.emit()
	return result


func stop_server() -> void:
	var was_started := is_started
	if _connection:
		_connection.destroy()
	_connection = null
	is_started = false
	if was_started:
		stopped.emit()


func send_packet(packet: PackedByteArray, client: MultiplayerClientIdentity) -> void:
	client.peer.send(0, packet, 0)


func broadcast_packet(packet: PackedByteArray) -> void:
	for client in clients:
		client.peer.send(0, packet, 0)
