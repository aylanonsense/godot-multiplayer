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


static func reposition_window(window: Window, position: String) -> void:
	var screen_rect := DisplayServer.screen_get_usable_rect(window.current_screen)
	var top_gap := 150
	var gap := 75
	var half_gap := gap / 2
	var upper_left := screen_rect.position + Vector2i(gap, top_gap)
	var width := screen_rect.size.x - 2 * gap
	var half_width := width / 2
	var height := screen_rect.size.y - top_gap - gap
	var half_height := height / 2
	match position:
		"full":
			window.position = upper_left
			window.size = Vector2i(width, height)
		"left":
			window.position = upper_left
			window.size = Vector2i(half_width - half_gap, height)
		"right":
			window.position = upper_left + Vector2i(half_width + half_gap, 0)
			window.size = Vector2i(half_width - half_gap, height)
		"upper-left":
			window.position = upper_left
			window.size = Vector2i(half_width - half_gap, half_height - half_gap)
		"lower-left":
			window.position = upper_left + Vector2i(0, half_height + half_gap)
			window.size = Vector2i(half_width - half_gap, half_height - half_gap)
		"upper-right":
			window.position = upper_left + Vector2i(half_width + half_gap, 0)
			window.size = Vector2i(half_width - half_gap, half_height - half_gap)
		"lower-right":
			window.position = upper_left + Vector2i(half_width + half_gap, half_height + half_gap)
			window.size = Vector2i(half_width - half_gap, half_height - half_gap)


static func parse_str_as_bool(s: String) -> bool:
	var cleaned_string := s.to_lower().strip_edges()
	return cleaned_string == "true" or cleaned_string == "1"


static func is_dedicated_server() -> bool:
	return OS.has_feature("dedicated_server")
