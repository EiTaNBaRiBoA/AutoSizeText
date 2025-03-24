@tool
class_name AutoSizeButton
extends Button

## watch_text_change true is needed for this event to work
signal text_changed(old_text: String, new_text: String)

## When true, text-size will be re-calculated when the text is changed.[br]
## Needed for the text_changed event to work.
@export
var watch_text_change: bool = true

@export_tool_button("FORCE REFRESH")
var refresh_button: Callable = _update_label()

@export_group("Auto Font Size")

## Min text size to reach
@export_range(1, 512, 1.0)
var min_font_size: int = 8:
	get:
		return min_font_size
	set(value):
		min_font_size = value
		if min_font_size >= max_font_size:
			min_font_size = max_font_size - 1
			push_warning(
				"min_font_size {0} >= max_font_size {1}, fixed to {2}"
				.format([value, max_font_size, min_font_size])
			)

		notify_property_list_changed()
		_sync_label()
		_update_label()

## Max text size to reach
@export_range(1, 512, 1.0)
var max_font_size: int = 38:
	get:
		return max_font_size
	set(value):
		max_font_size = value
		if max_font_size <= min_font_size:
			max_font_size = min_font_size + 1
			push_warning(
				"max_font_size {0} <= min_font_size {1}, fixed to {2}"
				.format([value, min_font_size, max_font_size])
			)

		notify_property_list_changed()
		_sync_label()
		_update_label()

@export_group("Step Size")

## Needs 2 numbers to work / will be automatically prefered over "Auto-Size"[br]
## when 2 numbers or more are present.
@export
var step_sizes: Array[int] = []:
	get:
		return step_sizes
	set(value):
		step_sizes = value
		step_sizes.sort()

		notify_property_list_changed()
		_sync_label()
		_update_label()


var _processing_flag: bool = false
var _label: AutoSizeLabel
var _saved_theme_colors: Dictionary[String, Color]


func _ready() -> void:
	# TODO: change defaults instead of hard-setting!

	# smalles possible font to force the button smallest size
	set(&"theme_override_font_sizes/font_size", 1)
	_prepare_colors()

	#if autowrap_mode == TextServer.AUTOWRAP_OFF:
	#	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#	push_warning("changed autowrap_mode to " + str(autowrap_mode))

	#if text_overrun_behavior == TextServer.AUTOWRAP_OFF:
	#	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	#	push_warning("changed text_overrun_behavior to " + str(text_overrun_behavior))

	clip_text = true
	
	if _label == null:
		_label = AutoSizeLabel.new()
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(_label)
		_label.set_anchors_preset(PRESET_FULL_RECT)
		
	_sync_label()	
	_update_label()
	#draw.connect(resize_text)
	#resized.connect(do_resize_text)
	#do_resize_text()


func _sync_label():
	_label.min_font_size = min_font_size
	_label.max_font_size = max_font_size
	_label.step_sizes = step_sizes


func _update_label():
	_label.text = text
	# TODO: detect current button state to pass on the color
	_sync_color("font_color")
	

func _prepare_colors():
	const colors_to_disable: Array[String] = [
		"font_color",
		"font_disabled_color",
		"font_hover_pressed_color",
		"font_hover_color",
	]
	
	for color_name in colors_to_disable:
		_saved_theme_colors[color_name] = get_theme_color(color_name, "Button")
		set("theme_override_colors/" + color_name, Color(0, 0, 0, 0))


func _sync_color(color_type: String) -> void:
	var theme_color: Color = _saved_theme_colors[color_type] #get_theme_color(color_type, "Button")
	print(theme_color)
	_label.set(&"theme_override_colors/font_color", theme_color)


func _process(_delta: float) -> void:
	if watch_text_change:
		if text != _label.text:
			_update_label()

			if not Engine.is_editor_hint():
				text_changed.emit(_label.text, text)

			_label.text = text
