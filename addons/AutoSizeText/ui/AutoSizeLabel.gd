@tool
extends Label
class_name AutoSizeLabel

@export_group("Inspector Buttons")

@export_tool_button("FORCE REFRESH")
var refresh_button = do_resize_text.bind()

@export_group("Auto-Size")

var _min_font_size: int = 8
@export
var min_font_size: int:
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
@export
var max_font_size: int:
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


var font_size: int = 0

func _ready() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	font_size = min_font_size
	draw.connect(resize_text)
	resized.connect(do_resize_text)
	do_resize_text()

func resize_text() -> void:
	if not needs_resize():
		return
		
	do_resize_text()
	
func do_resize_text():
	print("do_resize_text")
	for i in range(max_font_size, min_font_size, -1):
		set("theme_override_font_sizes/font_size", i)
		#emit_signal("item_rect_changed")

		custom_minimum_size = Vector2(0, 1)
		if not needs_resize():
			font_size = i
			print("font_size: " + str(font_size))
			break
	
func needs_resize() -> bool:
	return get_line_count() > get_visible_line_count()
