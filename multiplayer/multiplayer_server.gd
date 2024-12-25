class_name MultiplayerServer
extends Node


signal something_happened(text: String)

var _connection: ENetConnection


func start_server(port: int) -> Error:
	_connection = ENetConnection.new()
	var address := "127.0.0.1"
	var result := _connection.create_host_bound(address, port)
	if result != OK:
		if _connection:
			_connection.destroy()
		_connection = null
	print("Server listening on address %s port %d" % [address, port])
	return result


func _process(_delta: float) -> void:
	while _connection:
		var event := _connection.service()
		if not event:
			break
		var event_type: ENetConnection.EventType = event[0]
		if event_type != ENetConnection.EventType.EVENT_NONE:
			print("Server received %s" % Utils.enet_event_type_string(event_type))
			something_happened.emit("Server received %s" % Utils.enet_event_type_string(event_type))
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
				print("Server received number %d" % number)
				something_happened.emit("Server received number %d" % number)
				for other_peer in _connection.get_peers():
					var new_packet := PackedByteArray()
					new_packet.resize(1)
					new_packet.encode_u8(0, number)
					other_peer.send(0, new_packet, 0)
