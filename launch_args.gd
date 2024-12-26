extends Node


var server := false
var auto_start := false
var client := false
var auto_connect := false
var address := ""
var has_address: bool:
	get(): return not address.is_empty()
var port := -1
var has_port: bool:
	get(): return port >= 0
var window_placement := ""
var has_window_placement: bool:
	get(): return not window_placement.is_empty()
var warnings: Array[String] = []


func _ready() -> void:
	for arg in OS.get_cmdline_args():
		_parse_arg(arg, false)
	for arg in OS.get_cmdline_user_args():
		_parse_arg(arg, true)


func print_args() -> void:
	if server:
		print("server=true")
	if auto_start:
		print("auto-start=true")
	if client:
		print("client=true")
	if auto_connect:
		print("auto-connect=true")
	if has_address:
		print("address=%s" % address)
	if has_port:
		print("port=%d" % port)
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
			server = is_flag or Utils.parse_str_as_bool(value)
		"auto-start":
			auto_start = is_flag or Utils.parse_str_as_bool(value)
		"client":
			client = is_flag or Utils.parse_str_as_bool(value)
		"auto-connect":
			auto_connect = is_flag or Utils.parse_str_as_bool(value)
		"address":
			address = value
		"port":
			port = int(value)
		"window-placement":
			window_placement = value
		_:
			if complain_if_unknown_arg:
				warnings.append("Unknown launch argument \"%s\"" % key)
