@tool
extends Label
class_name AutoSizeLabel

@export_group("Inspector Buttons")

@export_tool_button("FORCE REFRESH")
var refresh_button : Callable = do_resize_text

@export_group("Auto-Size")

var _min_font_size: int = 8
@export_range(1, 512, 1.0)
var min_font_size: int = _min_font_size:
	get:
		return _min_font_size
	set(value):
		_min_font_size = value
		if _min_font_size >= max_font_size:
			_min_font_size = max_font_size - 1
			push_warning(
				"min_font_size {0} >= max_font_size {1}, fixed to {2}"
				.format([value, max_font_size, _min_font_size])
			)

		notify_property_list_changed()
		resize_text()

var _max_font_size: int = 38
@export_range(1, 512, 1.0)
var max_font_size: int = _max_font_size:
	get:
		return _max_font_size
	set(value):
		_max_font_size = value
		if _max_font_size <= min_font_size:
			_max_font_size = min_font_size + 1
			push_warning(
				"max_font_size {0} <= min_font_size {1}, fixed to {2}"
				.format([value, min_font_size, _max_font_size])
			)

		notify_property_list_changed()
		resize_text()

var _processing_flag: bool = false


func _ready() -> void:
	# TODO: change defaults instead of hard-setting!

	if autowrap_mode == TextServer.AUTOWRAP_OFF:
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		push_warning("changed autowrap_mode to " + str(autowrap_mode))

	if text_overrun_behavior == TextServer.AUTOWRAP_OFF:
		text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		push_warning("changed text_overrun_behavior to " + str(text_overrun_behavior))

	clip_text = true

	draw.connect(resize_text)
	resized.connect(do_resize_text)
	do_resize_text()


func resize_text() -> void:
	if not needs_resize():
		return

	do_resize_text()


func do_resize_text() -> void:
	# Prevent draw call stack handler
	if _processing_flag:
		return 
	
	_processing_flag = true
	for i: int in range(max_font_size, min_font_size, -1):
		set(&"theme_override_font_sizes/font_size", i)

		# force a refresh before checking needs_resize
		custom_minimum_size = Vector2(custom_minimum_size.x, custom_minimum_size.y)

		if not needs_resize():
			break
	
	_processing_flag = false


func needs_resize() -> bool:
	return get_line_count() > get_visible_line_count()
