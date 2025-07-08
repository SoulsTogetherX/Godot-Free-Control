# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name HoldButton extends Control
## A [Control] node used for hold buttons.

#region Signals
## Emits the state of the button as it is pressed.
## [br][br]
## Also see [member toggle_mode] and [signal button_state].
signal pressed_state(val : bool)
## Emits the state of the button as it is released.
## [br][br]
## Also see [member toggle_mode] and [signal button_state].
signal release_state(val : bool)
## Emits the state of the button as it is pressed or released.
## [br][br]
## Also see [signal pressed_state] and [signal release_state].
signal button_state(val : bool)


## Emits when button is released with all vaild conditions.
## [br][br]
## Also see [member release_when_outside] and [member cancel_when_outside].
signal press_vaild
## Emits when button is released without all vaild conditions.
## [br][br]
## Also see [member release_when_outside] and [member cancel_when_outside].
signal press_invaild


## Emits when press starts.
signal press_start
## Emits when press ends.
signal press_end
#endregion


#region External Variables
## If [code]true[/code], the button's state is pressed. Means the button is pressed down
## or toggled (if [member toggle_mode] is active). Only works if [member toggle_mode] is
## [code]false[/code].
@export var button_pressed : bool
## If [code]true[/code], the button is in [member toggle_mode]. Makes the button
## flip state between pressed and unpressed each time its area is clicked.
@export var toggle_mode : bool:
	set(val):
		if toggle_mode != val:
			toggle_mode = val
			if !val:
				button_pressed = false
			
			notify_property_list_changed()
## If [code]true[/code], then this node does not accept input.
@export var disabled : bool:
	set(val):
		if disabled != val:
			disabled = val
			_bounds_check.disabled = val
			_distance_check.disabled = val


@export_group("Release At")
## If [code]true[/code], the button's held state is released if input moves outside of
## bounds.
@export var release_when_outside : bool = true:
	set(val):
		release_when_outside = val
		_bounds_check.release_when_outside = val
## If [code]true[/code], the button's held state is released and all checking is stopped
## if input moves outside of bounds.
@export var cancel_when_outside : bool = true:
	set(val):
		cancel_when_outside = val
		_bounds_check.cancel_when_outside = val

@export_group("Release On Drag")
## The current check mode.
##
## Also see [enum CHECK_MODE].
@export var mode : DistanceCheck.CHECK_MODE = DistanceCheck.CHECK_MODE.BOTH:
	set(val):
		mode = val
		_distance_check.mode = val
## The max pixels difference, between the start and current position, that can be tolerated.
@export_range(0, 500, 0.001, "or_greater", "suffix:px") var distance : float = 30:
	set(val):
		distance = val
		_distance_check.distance = val
#endregion


#region Private Variables
var _bounds_check : BoundsCheck
var _distance_check : DistanceCheck
#endregion


#region Private Virtual Methods
func _init() -> void:
	if _distance_check && is_instance_valid(_distance_check):
		_distance_check.queue_free()
	_distance_check = DistanceCheck.new()
	_distance_check.name = "distance_check"
	_distance_check.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_distance_check)
	
	_distance_check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_distance_check.cancel_when_outside = true
	_distance_check.disabled = disabled
	_distance_check.mode = mode
	_distance_check.distance = distance
	
	
	_distance_check.pos_exceeded.connect(force_release)
	
	
	if _bounds_check && is_instance_valid(_bounds_check):
		_bounds_check.queue_free()
	_bounds_check = BoundsCheck.new()
	_bounds_check.name = "bounds_check"
	_bounds_check.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bounds_check)
	
	_bounds_check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bounds_check.disabled = disabled
	_bounds_check.release_when_outside = release_when_outside
	_bounds_check.cancel_when_outside = cancel_when_outside
	
	_bounds_check.end_vaild.connect(_on_end_vaild)
	_bounds_check.end_invaild.connect(_on_end_invaild)
	_bounds_check.start_check.connect(_on_start_check)
	_bounds_check.end_check.connect(_on_end_check)
func _validate_property(property: Dictionary) -> void:
	if property.name == "button_pressed":
		if !toggle_mode:
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion || event is InputEventScreenDrag || event is InputEventMouseButton || event is InputEventScreenTouch:
		event.position += global_position
		_bounds_check._gui_input(event)
		_distance_check._gui_input(event)
#endregion


#region Private Methods
func _on_start_check() -> void:
	press_start.emit()
	
	if toggle_mode:
		button_pressed = !button_pressed
	else:
		button_pressed = true
	button_state.emit(button_pressed)
	pressed_state.emit(button_pressed)
func _on_end_check() -> void:
	_distance_check.force_release()
	press_end.emit()
func _on_end_vaild() -> void:
	press_vaild.emit()
	
	if !toggle_mode:
		button_pressed = false
	button_state.emit(button_pressed)
	release_state.emit(button_pressed)
func _on_end_invaild() -> void:
	press_invaild.emit()
	
	if toggle_mode:
		button_pressed = !button_pressed
	else:
		button_pressed = false
	button_state.emit(button_pressed)
	release_state.emit(button_pressed)
#endregion


#region Public Methods
## Forcibly stops this node's check.
func force_release() -> void:
	_bounds_check.force_release()
	_distance_check.force_release()
	
	_on_end_invaild()
## Returns if mouse or touch is being held (mouse or touch outside of limit without being released).
## [br][br]
## Also see [method force_release].
func is_held() -> bool:
	return _bounds_check.is_checking()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
