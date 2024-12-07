class_name Utils


const MULTIPLAYER_SERVER_ID := 1

static func get_parsed_cmdline_args() -> Dictionary:
	var arguments := {}
	for argument in OS.get_cmdline_args():
		var key: String
		var value: String
		var is_flag: bool
		if argument.contains("="):
			var key_and_value := argument.split("=")
			key = key_and_value[0].trim_prefix("--").to_lower()
			value = key_and_value[1]
			is_flag = false
		else:
			key = argument.trim_prefix("--").to_lower()
			value = ""
			is_flag = true
		match key:
			"start-network": arguments[key] = is_flag or parse_str_as_bool(value)
			"num-clients": if not is_flag: arguments[key] = int(value)
	return arguments


static func parse_str_as_bool(s: String) -> bool:
	return s.to_lower() == "true" or s == "1"
