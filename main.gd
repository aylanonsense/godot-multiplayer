extends Node


@export var server_scene: PackedScene
@export var client_scene: PackedScene

var server: MultiplayerServer
var clients := [] as Array[MultiplayerClient]


func _ready() -> void:
	var args := Utils.get_parsed_cmdline_args()
	if args.has("simulate-network") and args["simulate-network"]:
		_spawn_and_start_server()
		for i in range(args["num-clients"] if args.has("num-clients") else 1):
			_spawn_client_and_connect_to_server()


func _spawn_and_start_server() -> void:
	server = server_scene.instantiate()
	server.name = "Server"
	add_child(server)
	server.server_started.connect(_on_server_started)
	server.server_failed_to_start.connect(_on_server_failed_to_start)
	server.server_stopped.connect(_on_server_stopped)
	server.client_connected.connect(_on_server_client_connected)
	server.client_disconnected.connect(_on_server_client_disconnected)
	server.start_server()


func _spawn_client_and_connect_to_server() -> void:
	var client := client_scene.instantiate() as MultiplayerClient
	client.name = "Client %d" % (clients.size() + 1)
	add_child(client)
	clients.append(client)
	client.started_connecting_to_server.connect(_on_client_started_connecting_to_server.bind(client))
	client.connected_to_server.connect(_on_client_connected_to_server.bind(client))
	client.connection_failed.connect(_on_client_connection_failed.bind(client))
	client.disconnected_from_server.connect(_on_client_disconnected_from_server.bind(client))
	client.client_connected.connect(_on_client_connected.bind(client))
	client.client_disconnected.connect(_on_client_disconnected.bind(client))
	client.connect_to_server()


# Server signals
func _on_server_started() -> void:
	print("Server :: Started")


func _on_server_stopped() -> void:
	print("Server :: Stopped")


func _on_server_failed_to_start(_result: MultiplayerServer.StartServerResult) -> void:
	print("Server :: Failed to start")
	

func _on_server_client_connected(id: int) -> void:
	print("Server :: Client %d connected" % id)


func _on_server_client_disconnected(id: int) -> void:
	print("Server :: Client %d disconnected" % id)


# Client signals
func _on_client_started_connecting_to_server(client: MultiplayerClient) -> void:
	print("%s :: Started connecting to server" % client.name)


func _on_client_connected_to_server(id: int, client: MultiplayerClient) -> void:
	print("%s :: Connected to server as %d" % [client.name, id])


func _on_client_connection_failed(_cause: MultiplayerClient.ConnectionFailCause, client: MultiplayerClient) -> void:
	print("%s :: Connection failed" % client.name)


func _on_client_disconnected_from_server(client: MultiplayerClient) -> void:
	print("%s :: Disconnected from server" % client.name)


func _on_client_connected(id: int, client: MultiplayerClient) -> void:
	print("%s :: Client %d connected" % [client.name, id])


func _on_client_disconnected(id: int, client: MultiplayerClient) -> void:
	print("%s :: Client %d disconnected" % [client.name, id])
