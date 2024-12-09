class_name MultiplayerClientRoot
extends Node


var multiplayer_api: MultiplayerAPI


func _enter_tree() -> void:
	if not multiplayer_api:
		multiplayer_api = MultiplayerAPI.create_default_interface()
		multiplayer_api.multiplayer_peer = null
	get_tree().set_multiplayer(multiplayer_api, get_path())


func connect_to_server(address: String, port: int) -> Error:
	var multiplayer_peer := ENetMultiplayerPeer.new()
	var result := multiplayer_peer.create_client(address, port)
	if result == OK:
		multiplayer_api.multiplayer_peer = multiplayer_peer
	return result
