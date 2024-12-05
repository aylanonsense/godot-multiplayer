class_name MultiplayerClient
extends Node


signal started_connecting_to_server()
signal connected_to_server(id: int)
signal connection_failed(cause: ConnectionFailCause)
signal disconnected_from_server()
signal client_connected(id: int)
signal client_disconnected(id: int)

enum Status {
	DISCONNECTED,
	CONNECTING,
	CONNECTED
}

enum ConnectionFailCause {
	UNKNOWN,
	CONNECTION_ALREADY_IN_USE,
	CANT_CREATE_CLIENT
}

@export var address := "127.0.0.1"
@export var port := 12345
@export var compression: ENetConnection.CompressionMode = ENetConnection.CompressionMode.COMPRESS_NONE

var status := Status.DISCONNECTED
var multiplayer_api: MultiplayerAPI


func _ready() -> void:
	multiplayer_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(multiplayer_api, get_path())
	multiplayer_api.connected_to_server.connect(_connected_to_server)
	multiplayer_api.connection_failed.connect(_connection_failed)
	multiplayer_api.peer_connected.connect(_peer_connected)
	multiplayer_api.peer_disconnected.connect(_peer_disconnected)
	multiplayer_api.server_disconnected.connect(_server_disconnected)


func connect_to_server() -> void:
	if status != Status.DISCONNECTED:
		return
	multiplayer_api.multiplayer_peer = null
	status = Status.CONNECTING
	started_connecting_to_server.emit()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, port)
	if result != OK:
		status = Status.DISCONNECTED
		match result:
			ERR_ALREADY_IN_USE:
				connection_failed.emit(ConnectionFailCause.CONNECTION_ALREADY_IN_USE)
			ERR_CANT_CREATE:
				connection_failed.emit(ConnectionFailCause.CANT_CREATE_CLIENT)
			_:
				connection_failed.emit(ConnectionFailCause.UNKNOWN)
		return
	peer.host.compress(compression)
	multiplayer_api.multiplayer_peer = peer


func disconnect_from_server() -> void:
	if status != Status.CONNECTED:
		return
	status = Status.DISCONNECTED
	multiplayer_api.multiplayer_peer = null
	disconnected_from_server.emit()


func get_client_id() -> int:
	return multiplayer_api.get_unique_id()


func is_connected_to_server() -> bool:
	return status == Status.CONNECTED


func _connected_to_server() -> void:
	status = Status.CONNECTED
	connected_to_server.emit(multiplayer_api.get_unique_id())


func _connection_failed() -> void:
	if status != Status.CONNECTING:
		return
	status = Status.DISCONNECTED
	multiplayer_api.multiplayer_peer = null
	connection_failed.emit(ConnectionFailCause.UNKNOWN)


func _server_disconnected() -> void:
	match status:
		Status.CONNECTING:
			status = Status.DISCONNECTED
			multiplayer_api.multiplayer_peer = null
			connection_failed.emit(ConnectionFailCause.UNKNOWN)
		Status.CONNECTED:
			status = Status.DISCONNECTED
			multiplayer_api.multiplayer_peer = null
			disconnected_from_server.emit()


func _peer_connected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_connected.emit(id)


func _peer_disconnected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_disconnected.emit(id)
