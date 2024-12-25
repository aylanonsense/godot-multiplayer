class_name Utils


static func enet_event_type_string(event_type: ENetConnection.EventType) -> String:
	match event_type:
		ENetConnection.EventType.EVENT_ERROR: return "Error"
		ENetConnection.EventType.EVENT_NONE: return "None"
		ENetConnection.EventType.EVENT_CONNECT: return "Connect"
		ENetConnection.EventType.EVENT_DISCONNECT: return "Disconnect"
		ENetConnection.EventType.EVENT_RECEIVE: return "Receive"
	return ""


static func enet_peer_state_string(state: ENetPacketPeer.PeerState) -> String:
	match state:
		ENetPacketPeer.PeerState.STATE_DISCONNECTED: return "Disconnected"
		ENetPacketPeer.PeerState.STATE_CONNECTING: return "Connecting"
		ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_CONNECT: return "Acknowledging connect"
		ENetPacketPeer.PeerState.STATE_CONNECTION_PENDING: return "Connection pending"
		ENetPacketPeer.PeerState.STATE_CONNECTION_SUCCEEDED: return "Connection succeeded"
		ENetPacketPeer.PeerState.STATE_CONNECTED: return "Connected"
		ENetPacketPeer.PeerState.STATE_DISCONNECT_LATER: return "Disconnect later"
		ENetPacketPeer.PeerState.STATE_DISCONNECTING: return "Disconnecting"
		ENetPacketPeer.PeerState.STATE_ACKNOWLEDGING_DISCONNECT: return "Acknowledging disconnect"
		ENetPacketPeer.PeerState.STATE_ZOMBIE: return "Zombie"
	return ""
