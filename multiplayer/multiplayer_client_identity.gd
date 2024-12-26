class_name MultiplayerClientIdentity


var id := -1
var peer: ENetPacketPeer


func _init(id: int, peer: ENetPacketPeer) -> void:
	self.id = id
	self.peer = peer
