class_name MultiplayerNetwork
extends Node


signal server_created(server: MultiplayerServer)
signal client_created(client: MultiplayerClient)

@export var server_scene: PackedScene
@export var client_scene: PackedScene

var servers := [] as Array[MultiplayerServer]
var clients := [] as Array[MultiplayerClient]


func create_server() -> MultiplayerServer:
	var server := server_scene.instantiate() as MultiplayerServer
	servers.append(server)
	var num_servers := servers.size()
	server.name = "Server" if num_servers == 1 else ("Server%d" % num_servers)
	add_child(server)
	server_created.emit(server)
	return server


func create_client() -> MultiplayerClient:
	var client := client_scene.instantiate() as MultiplayerClient
	clients.append(client)
	var num_clients := clients.size()
	client.name = "Client" if num_clients == 1 else ("Client%d" % num_clients)
	add_child(client)
	client_created.emit(client)
	return client
