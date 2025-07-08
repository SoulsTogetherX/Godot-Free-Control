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
## The largest possible size for a font
const MAX_FONT_SIZE := 4096
## The smallest possible size for a font
const MIN_FONt_SIZE := 1
#endregion


#region External Variables
## The max size the font should scale up to. Too high a difference from [member min_size]
## may cause lag.
## [br]
## Cannot be less than [member min_size]. If set to [code]-1[/code], the upper bound will be removed.
@export var max_size : int = 100:
	set(val):
		if max_size != val:
			if val <= -1:
				val = -1
			elif val < min_size:
				val = min_size
			
			max_size = val
			
			if is_node_ready():
				update_font_size()
## The min size the font should scale up to. Too high a difference from [member max_size]
## may cause lag.
## [br]
## Cannot exceed [member max_size] or be less than [code]1[/code].
@export var min_size : int = 1:
	set(val):
		if min_size != val:
			if val <= 0:
				val = 1
			elif val > max_size:
				val = max_size
			
			min_size = val
			
			if is_node_ready():
				update_font_size()
@export var stop_resizing : bool:
	set(val):
		if stop_resizing != val:
			stop_resizing = val
			
			if !val:
				update_font_size()
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
			text = value
			update_font_size()
			return true
		"label_settings":
			if label_settings == value:
				return true
			
			if label_settings:
				label_settings.changed.disconnect(_on_theme_update)
			label_settings = value
			if label_settings:
				label_settings.changed.connect(_on_theme_update)
			
			update_font_size()
			return true
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			update_font_size()
		NOTIFICATION_THEME_CHANGED:
			_on_theme_update()
#endregion


#region Private Methods
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

func _check_smaller_than_ideal() -> bool:
	var paragraph_size := _paragraph.get_size()
	return floor(size.x) > paragraph_size.x && floor(size.y) > paragraph_size.y
func _check_greater_than_ideal() -> bool:
	var paragraph_size := _paragraph.get_size()
	return floor(size.x) < paragraph_size.x || floor(size.y) < paragraph_size.y

func _get_max_allow(fontFile : FontFile) -> int:
	var ret_size := _current_font_size
	
	while _check_smaller_than_ideal() || ret_size >= MAX_FONT_SIZE:
		ret_size <<= 1
		
		_paragraph.clear()
		_paragraph.add_string(
			text, fontFile, ret_size
		)
	return min(ret_size, MAX_FONT_SIZE)


func _on_theme_update() -> void:
	if _state:
		_state &= ~LABEL_STATE.IGNORE
		return
	_state = LABEL_STATE.NONE
	
	call_deferred("_update_font_size")
func _update_font_size() -> void:
	_state = LABEL_STATE.NONE
	if text.is_empty() || stop_resizing:
		return
	
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


#region Public Methods
## Queues the font size to update. This method runs on an automatic deffered call.
## Calling it multiple times before the deffered call runs does nothing.
func update_font_size() -> void:
	if _state:
		return
	_state |= LABEL_STATE.QUEUED
	
	call_deferred("_update_font_size")
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
