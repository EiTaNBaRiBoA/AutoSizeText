@tool
extends TextEdit
# # # # # # # # # # # # # # # # # # # # # # # # # # #
# Twister
#
# AutoSize TextEdit.
# # # # # # # # # # # # # # # # # # # # # # # # # # #
@export_category("Auto Size TextEdit")
@export_tool_button("FORCE REFRESH")
var refresh_button: Callable = _on_change_rect

@export_group("Font Size")
@export_range(1, 512) var max_size : int = 38:
	set(new_max):
		max_size = max(min_size, min(new_max,512))
		if is_node_ready():
			_on_change_rect()

@export_range(1, 512) var min_size : int = 8:
	set(new_min):
		min_size = min(max(1, new_min), max_size)
		if is_node_ready():
			_on_change_rect()

var _processing_flag : bool = false

func _set(property: StringName, _value: Variant) -> bool:
	if property == &"text" or \
	property == &"placeholder_text":
		_on_change_rect.call_deferred()
	return false

func _ready() -> void:
	item_rect_changed.connect(_on_change_rect)
	_on_change_rect.call_deferred()

func _on_change_rect() -> void:
	if _processing_flag:return
	_processing_flag = true

	const OFFSET_BY : String = "_" #Taking custom char offset prevent text clip by rect
	var font : Font = get(&"theme_override_fonts/font")
	var c_size : int = max_size
	var fsize_x : float = 0.0
	var offset : float = 0.0

	#region kick_falls
	var use_placeholder : bool = false
	var current_text : String = text
	if current_text.is_empty():
		if placeholder_text.is_empty():return
		current_text = placeholder_text
		use_placeholder = true

	if null == font:
		font = get_theme_default_font()
	#endregion

	var txt : PackedStringArray = current_text.split('\n', true, 0)
	for st : String in txt:
		var size_offset : Vector2 = font.get_string_size(st, HORIZONTAL_ALIGNMENT_LEFT, -1, c_size , TextServer.JUSTIFICATION_NONE,TextServer.DIRECTION_AUTO,TextServer.ORIENTATION_HORIZONTAL)
		fsize_x = maxf(fsize_x, size_offset.x)

	offset = size.x - font.get_string_size(OFFSET_BY, HORIZONTAL_ALIGNMENT_LEFT, -1, c_size, TextServer.JUSTIFICATION_NONE,TextServer.DIRECTION_AUTO,TextServer.ORIENTATION_HORIZONTAL).x

	if use_placeholder:
		#HACK: Lines updated response by text only
		text = placeholder_text

	# Refresh rect
	set(&"theme_override_font_sizes/font_size", c_size)
	while offset < fsize_x or get_line_count() > get_visible_line_count():
		c_size = c_size - 1

		if c_size < min_size:
			c_size = min_size
			break

		fsize_x = 0.0
		for st : String in txt:
			var size_offset : Vector2 = font.get_string_size(st, HORIZONTAL_ALIGNMENT_LEFT, -1, c_size , TextServer.JUSTIFICATION_NONE,TextServer.DIRECTION_AUTO,TextServer.ORIENTATION_HORIZONTAL)
			fsize_x = maxf(fsize_x, size_offset.x)
		offset = size.x - font.get_string_size(OFFSET_BY, HORIZONTAL_ALIGNMENT_LEFT, -1, c_size , TextServer.JUSTIFICATION_NONE,TextServer.DIRECTION_AUTO,TextServer.ORIENTATION_HORIZONTAL).x

		# Refresh rect
		set(&"theme_override_font_sizes/font_size", c_size)

	#Set final result
	set(&"theme_override_font_sizes/font_size", c_size)

	if use_placeholder:
		# Restore
		text = ""
	set_deferred(&"_processing_flag", false)
