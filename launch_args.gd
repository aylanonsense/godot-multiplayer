extends Node


var server: bool
var has_server_flag := false
var auto_connect: bool
var has_auto_connect_flag := false
var address: String
var has_address := false
var port: int
var has_port := false
var window_placement: String
var has_window_placement := false
var warnings: Array[String] = []


func _ready() -> void:
	for arg in OS.get_cmdline_args():
		_parse_arg(arg, false)
	for arg in OS.get_cmdline_user_args():
		_parse_arg(arg, true)


func print_args() -> void:
	if has_server_flag:
		print("server=%s" % server)
	if has_auto_connect_flag:
		print("auto-connect=%s" % auto_connect)
	if has_address:
		print("address=%s" % address)
	if has_port:
		print("port=%s" % port)
	if has_window_placement:
		print("window-placement=%s" % window_placement)


func print_warnings() -> void:
	for warning in warnings:
		print(warning)


func _parse_arg(arg: String, complain_if_unknown_arg: bool) -> void:
	var key: String
	var value: String
	var is_flag: bool
	if arg.contains("="):
		var key_and_value := arg.split("=", true, 1)
		key = key_and_value[0].trim_prefix("--").to_lower()
		value = key_and_value[1].trim_prefix("\"").trim_suffix("\"").strip_edges()
		is_flag = false
	else:
		key = arg.trim_prefix("--").to_lower()
		value = ""
		is_flag = true
	match key:
		"server":
			server = is_flag or _parse_str_as_bool(value)
			has_server_flag = true
		"auto-connect":
			auto_connect = is_flag or _parse_str_as_bool(value)
			has_auto_connect_flag = true
		"address":
			if is_flag or not value.is_valid_ip_address():
				warnings.append("Launch argument \"%s\" must be an IP address" % key)
			else:
				address = value
				has_address = true
		"port":
			if is_flag or not value.is_valid_int():
				warnings.append("Launch argument \"%s\" must be an integer" % key)
			else:
				port = int(value)
				has_port = true
		"window-placement":
			if is_flag or value.is_empty():
				warnings.append("Launch argument \"%s\" must be given a value" % key)
			else:
				window_placement = value
				has_window_placement = true
		_:
			if complain_if_unknown_arg:
				warnings.append("Unknown launch argument \"%s\"" % key)


func _parse_str_as_bool(s: String) -> bool:
	return s.to_lower() == "true" or s == "1"
