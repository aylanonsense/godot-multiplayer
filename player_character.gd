class_name PlayerCharacter
extends CharacterBody3D


#var player_id := Utils.MULTIPLAYER_SERVER_ID:
	#set(value):
		#player_id = value
		#%MultiplayerSynchronizer.set_multiplayer_authority(value)

@onready var player_id_label := %PlayerIDLabel as Label3D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	player_id_label.text = str(get_multiplayer_authority())


func _physics_process(_delta: float) -> void:
	player_id_label.text = str(get_multiplayer_authority())
	if not is_multiplayer_authority():
		return
	var move := Input.get_vector(&"move_left", &"move_right", &"move_backward", &"move_forward")
	velocity = 10.0 * Vector3(move.x, 0.0, -move.y)
	move_and_slide()
