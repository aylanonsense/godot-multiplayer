class_name Utils


const MULTIPLAYER_SERVER_PEER_ID := 1
const DEFAULT_SERVER_PORT_ID := 8817


static func is_dedicated_server() -> bool:
	return OS.has_feature("dedicated_server")
