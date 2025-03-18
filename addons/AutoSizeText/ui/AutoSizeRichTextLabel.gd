@tool
# # # # # # # # # # # # # # # # # # # # # # # # # # #
# Twister
#
# Following the context of the main AutoSize addon.
# # # # # # # # # # # # # # # # # # # # # # # # # # #
extends RichTextLabel
class_name AutoSizeRichTextLabel

@export_group("Inspector Buttons")

@export_tool_button("FORCE REFRESH")
var refresh_button: Callable = do_resize_text

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

var _processing_flag : bool = false


func _ready() -> void:
	# TODO: change defaults instead of hard-setting!

	if autowrap_mode == TextServer.AUTOWRAP_OFF:
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		push_warning("changed autowrap_mode to " + str(autowrap_mode))

	bbcode_enabled = true

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
	
	if fit_content:
		push_warning("Fit content can't be used (program freeze), setting it to false!")
		fit_content = false
	
	if !text.begins_with("[font_size="):
		set(&"text", "[font_size={0}]{1}[/font_size]".format([max_font_size, text]))
	else:
		set(&"text", "[font_size={0}]{1}".format([max_font_size, text.substr(text.find("]", 0) + 1, -1)]))
	
	_processing_flag = false
	reisze_text.call_deferred()


func reisze_text() -> void:
	var font_size : int = 0
	for i : int in range(max_font_size, min_font_size, -1):
		font_size = i
		set(&"text", "[font_size={0}]{1}".format([font_size, text.substr(text.find("]", 0) + 1, -1)]))

		if not visible_lines(i):
			break


func visible_lines(char_size : float) -> bool:
	char_size = (maxf(char_size,0.01) / 12.0) * 16.0
	return get_line_count() > int(maxf(size.y, 0.01) / (char_size))


func needs_resize() -> bool:
	return (get_line_count() > get_visible_line_count())
