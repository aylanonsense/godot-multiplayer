class_name MultiplayerServerControlPanel
extends Control


@export var server: MultiplayerServer

@onready var _local_port_label := %LocalPortLabel as Label
@onready var _num_peers_label := %NumPeersLabel as Label
@onready var _log_view := %LogView as LogView


func _ready() -> void:
	server.something_happened.connect(_on_server_something_happened)


func _process(_delta: float) -> void:
	_local_port_label.text = "local_port=%d" % server._connection.get_local_port()
	_num_peers_label.text = "num_peers=%d" % server._connection.get_peers().size()


func _on_server_something_happened(text: String):
	_log_view.add_log_line(text)
