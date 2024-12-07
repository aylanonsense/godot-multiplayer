extends Node


@onready var network := %MultiplayerNetwork as MultiplayerNetwork


func _ready() -> void:
	var args := Utils.get_parsed_cmdline_args()
	var auto_start: bool = args.has("start-network") and args["start-network"]
	var num_clients: int = args["num-clients"] if args.has("num-clients") else 0
	if auto_start or num_clients > 0:
		var server := network.create_server()
		if auto_start:
			server.start_server()
	for i in range(num_clients):
		var client := network.create_client()
		if auto_start:
			client.connect_to_server()
