class_name LogView
extends Control


@onready var _scroll_container := %ScrollContainer as ScrollContainer
@onready var _log_line_template := %LogLineTemplate as Label
@onready var _log_line_container := _log_line_template.get_parent() as Container


func _ready() -> void:
	_log_line_template.visible = false
	_scroll_container.get_v_scroll_bar().changed.connect(_scroll_logs_to_bottom)


func add_log_line(text: String) -> void:
	var log_line := _log_line_template.duplicate() as Label
	log_line.text = text
	log_line.visible = true
	log_line.name = "LogLine"
	_log_line_container.add_child(log_line)


func clear_log_lines() -> void:
	for log_line in _log_line_container.get_children():
		if log_line != _log_line_template:
			_log_line_container.remove_child(log_line)
			log_line.queue_free() 


func _scroll_logs_to_bottom() -> void:
	_scroll_container.scroll_vertical = ceil(_scroll_container.get_v_scroll_bar().max_value)
