class_name PlayerCharacterSpawner
extends Node


@export var player_character_scene: PackedScene


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(id: int) -> void:
	if not is_multiplayer_authority():
		return
	if id == Utils.MULTIPLAYER_SERVER_ID:
		return
	var player_character := player_character_scene.instantiate() as PlayerCharacter
	player_character.name = str(id)
	add_child(player_character)
