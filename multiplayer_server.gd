class_name MultiplayerServer
extends Node


signal server_started()
signal server_failed_to_start(result: StartServerResult)
signal server_stopped()
signal client_connected(id: int)
signal client_disconnected(id: int)

enum StartServerResult {
	SUCCESS,
	SERVER_ALREADY_STARTED,
	CONNECTION_ALREADY_IN_USE,
	CANT_CREATE_SERVER,
	UNKNOWN_FAILURE
}

@export var port := 12345
@export var max_clients := 8
@export var compression: ENetConnection.CompressionMode = ENetConnection.CompressionMode.COMPRESS_NONE

var started := false
var multiplayer_api: MultiplayerAPI


func _ready() -> void:
	multiplayer_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(multiplayer_api, get_path())
	multiplayer_api.peer_connected.connect(_peer_connected)
	multiplayer_api.peer_disconnected.connect(_peer_disconnected)


func start_server() -> StartServerResult:
	if started:
		return StartServerResult.SERVER_ALREADY_STARTED
	multiplayer_api.multiplayer_peer = null
	started = true
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port, max_clients)
	if result != OK:
		started = false
		match result:
			ERR_ALREADY_IN_USE:
				server_failed_to_start.emit(StartServerResult.CONNECTION_ALREADY_IN_USE)
				return StartServerResult.CONNECTION_ALREADY_IN_USE
			ERR_CANT_CREATE:
				server_failed_to_start.emit(StartServerResult.CANT_CREATE_SERVER)
				return StartServerResult.CANT_CREATE_SERVER
			_:
				server_failed_to_start.emit(StartServerResult.UNKNOWN_FAILURE)
				return StartServerResult.UNKNOWN_FAILURE
	peer.host.compress(compression)
	multiplayer_api.multiplayer_peer = peer
	server_started.emit()
	return StartServerResult.SUCCESS


func stop_server() -> void:
	if not started:
		return
	started = false
	multiplayer_api.multiplayer_peer = null
	server_stopped.emit()


func _peer_connected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_connected.emit(id)


func _peer_disconnected(id: int) -> void:
	if id != Utils.MULTIPLAYER_SERVER_ID:
		client_disconnected.emit(id)
