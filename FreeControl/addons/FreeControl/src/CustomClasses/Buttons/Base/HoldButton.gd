# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name HoldButton extends BaseButton
## A [Control] node used to process input if held or released.


signal release_state(val : bool)
signal pressed_state(val : bool)

signal press_released_vaild

signal press_start
signal press_end



@export var release_when_outside : bool = true:
	set(val):
		if release_when_outside != val:
			release_when_outside = val
			_end_mouse_check()
@export var cancel_when_outside : bool = false
@export var button_pressed_state : bool = false:
	set(val):
		if button_pressed_state != val:
			button_pressed_state = val
			release_state.emit(button_pressed_state)


var _holding : bool = false



func is_held() -> bool: return _holding
func force_release() -> void:
	pressed_state.emit(button_pressed_state)
	
	if _holding:
		_end_mouse_check()
		_holding = false
		press_end.emit()


func _init() -> void:
	tree_exiting.connect(_end_mouse_check)
func _gui_input(event: InputEvent) -> void:
	if disabled || mouse_filter == MOUSE_FILTER_IGNORE: return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			if release_when_outside: _start_mouse_check()
			else:
				_holding = true
				press_start.emit()
				pressed_state.emit(!button_pressed_state)
		else:
			if release_when_outside: _end_mouse_check()
			if _holding:
				_holding = false
				press_end.emit()
				press_released_vaild.emit()
				if toggle_mode: button_pressed_state = !button_pressed_state
				pressed_state.emit(button_pressed_state)
				release_state.emit(button_pressed_state)
	
	if mouse_filter == MOUSE_FILTER_STOP && _holding:
		accept_event()
func _validate_property(property: Dictionary) -> void:
	if property.name == "button_pressed":
		property.usage &= ~PROPERTY_USAGE_EDITOR
	elif property.name == "button_pressed_state" && !toggle_mode:
		property.usage |= PROPERTY_USAGE_READ_ONLY
func _set(property: StringName, val: Variant) -> bool:
	if property == "toggle_mode":
		if toggle_mode != val:
			toggle_mode = val
			button_pressed_state = false
			notify_property_list_changed()
		return true
	elif property == "disabled":
		if disabled != val:
			disabled = val
			if val: force_release()
		return true
	return false

func _start_mouse_check() -> void:
	if is_inside_tree() && !get_tree().process_frame.is_connected(_mouse_check):
		get_tree().process_frame.connect(_mouse_check)
func _end_mouse_check() -> void:
	if is_inside_tree() && get_tree().process_frame.is_connected(_mouse_check):
		get_tree().process_frame.disconnect(_mouse_check)
func _mouse_check() -> void:
	if !_mouse_in_rect():
		if _holding:
			if cancel_when_outside: _end_mouse_check()
			press_end.emit()
			pressed_state.emit(button_pressed_state)
			_holding = false
	elif !_holding:
		press_start.emit()
		pressed_state.emit(!button_pressed_state)
		_holding = true

func _mouse_in_rect() -> bool:
	if !is_inside_tree(): return false
	return get_rect().has_point(get_local_mouse_position())

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
