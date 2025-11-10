# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AutoSizeLabel extends Label
## A [Label] node alternative that automatically increases the font size to
## fit within the contained boundaries.


#region Enums
## An enum for internal state management
enum LABEL_STATE {
	NONE = 0, ## Nothing
	QUEUED = 1, ## A font_size update has been queue, but not yet furfilled
	IGNORE = 2 ## An indication that the next update size calling should be ignored.
}
#endregion


#region Constants
## The largest possible dimension for a font
const MAX_FONT_DIMENSION := 4096
## The largest possible size for a font
const MAX_FONT_SIZE := 4096
## The smallest possible size for a font
const MIN_FONT_SIZE := 1
#endregion


#region External Variables
@export_group("Limits")
## The max size the font should scale up to. Too high a difference from [member min_size]
## may cause lag.
## [br]
## Cannot be less than [member min_size]. If set to [code]-1[/code], the upper bound will be removed.
@export var max_size : int = 100:
	set(val):
		val = -1 if val <= -1 else clampi(val, min_size, MAX_FONT_SIZE)
		
		if max_size != val:
			max_size = val
			_update_font_size_check()
## The min size the font should scale up to. Too high a difference from [member max_size]
## may cause lag.
## [br]
## Cannot exceed [member max_size] or be less than [code]1[/code].
@export var min_size : int = MIN_FONT_SIZE:
	set(val):
		val = clampi(val, MIN_FONT_SIZE, max_size)
		
		if min_size != val:
			min_size = max_size
			_update_font_size_check()

@export_group("Options")
@export_flags("x:1", "y:2") var resizing_on : int = 3:
	set(val):
		if resizing_on != val:
			resizing_on = val
			_update_font_size_check()
## If [code]true[/code], this label will stop automatically resizing the text font
## to it's size.
@export var stop_resizing : bool:
	set(val):
		if stop_resizing != val:
			stop_resizing = val
			_update_font_size_check()
## If [code]false[/code], this label will not resize if the text is changed to
## another text with the same length.
@export var resize_on_same_length : bool = false
#endregion


#region Private Variables
var _state : LABEL_STATE = LABEL_STATE.NONE

var _current_font_size : int = 1
var _paragraph := TextParagraph.new()
#endregion


#region Private Virtual Methods
func _init() -> void:
	clip_text = true
	autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	_state = LABEL_STATE.NONE

func _validate_property(property: Dictionary) -> void:
	if property.name in ["clip_text", "autowrap_mode", "text_overrun_behavior", "ellipsis_char"]:
		property.usage &= ~PROPERTY_USAGE_EDITOR

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			if text == value:
				return false
			if !resize_on_same_length && text.length() == value.length():
				text = value
				return false
			
			text = value
			_update_font_size_check()
			return true
		"label_settings":
			if label_settings == value:
				return true
			
			if label_settings:
				label_settings.changed.disconnect(_on_theme_update)
			label_settings = value
			if label_settings:
				label_settings.changed.connect(_on_theme_update)
			
			_update_font_size_check()
			return true
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			_update_font_size_check()
		NOTIFICATION_THEME_CHANGED:
			_on_theme_update()
#endregion


#region Private Methods (Size check)
func _check_smaller_than_ideal() -> bool:
	var paragraph_size := _paragraph.get_size()
	
	return (
		(!(resizing_on & 1) || (floorf(size.x) > paragraph_size.x)) &&
		(!(resizing_on & 2) || (floorf(size.y) > paragraph_size.y))
	)
func _check_greater_than_ideal() -> bool:
	var paragraph_size := _paragraph.get_size()
	
	return (
		((resizing_on & 1) && (floorf(size.x) < paragraph_size.x)) ||
		((resizing_on & 2) && (floorf(size.y) < paragraph_size.y))
	)
func _check_smaller_than_max() -> bool:
	var paragraph_size := _paragraph.get_size()
	
	return (
		MAX_FONT_DIMENSION >= paragraph_size.x &&
		MAX_FONT_DIMENSION >= paragraph_size.y
	)
func _get_max_allow(fontFile : FontFile) -> int:
	var ret_size := _current_font_size
	
	while _check_smaller_than_max() && _check_smaller_than_ideal():
		ret_size <<= 1
		
		_paragraph.clear()
		_paragraph.add_string(
			text, fontFile, ret_size
		)
	if !_check_smaller_than_max():
		ret_size >>= 1
	
	return mini(ret_size, MAX_FONT_SIZE)
#endregion


#region Private Methods (Font)
func _get_font_file() -> FontFile:
	var fontFile : FontFile
	if label_settings:
		if !label_settings.font:
			fontFile = get_theme_default_font()
		else:
			fontFile = label_settings.font
	elif has_theme_font("font"):
		fontFile = get_theme_font("font")
	else:
		fontFile = get_theme_default_font()
	return fontFile
func _update_font_size() -> void:
	_state = LABEL_STATE.NONE
	if text.is_empty() || resizing_on == 0:
		return
	
	var fontFile := _get_font_file()
	
	_paragraph.clear()
	_paragraph.add_string(
		text, fontFile, _current_font_size
	)
	
	if _check_smaller_than_ideal():
		var max_allow  := max_size if max_size >= 0 else _get_max_allow(fontFile)
		_current_font_size = _partition_ideal(_current_font_size, max_allow, fontFile)
	elif _check_greater_than_ideal():
		_current_font_size = _partition_ideal(min_size, _current_font_size, fontFile)
	
	_state |= LABEL_STATE.IGNORE
	if label_settings:
		label_settings.font_size = _current_font_size
		return
	add_theme_font_size_override("font_size", _current_font_size)
#endregion


#region Private Methods (On event)
func _on_theme_update() -> void:
	if _state:
		_state &= ~LABEL_STATE.IGNORE
		return
	_state = LABEL_STATE.NONE
	
	if !stop_resizing:
		update_font_size()
#endregion


#region Private Methods (Helper)
func _partition_ideal(start: int, end: int, fontFile : FontFile) -> int:
	if start + 1 >= end:
		return start
	
	var mid : int = (start + end) >> 1
	
	_paragraph.clear()
	_paragraph.add_string(
		text, fontFile, mid
	)
	
	if _check_smaller_than_ideal():
		return _partition_ideal(mid, end, fontFile)
	return _partition_ideal(start, mid, fontFile)

func _update_font_size_check() -> void:
	if is_node_ready() && !stop_resizing:
		update_font_size()
#endregion


#region Public Methods
## Queues the font size to update. This method runs on an automatic deffered call.
## Calling it multiple times before the deffered call runs does nothing.
## [br][br]
## [b]NOTE[b]: This works even when [member stop_resizing] is [code]true[/code].
func update_font_size() -> void:
	if _state:
		return
	_state |= LABEL_STATE.QUEUED
	
	call_deferred("_update_font_size")
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
