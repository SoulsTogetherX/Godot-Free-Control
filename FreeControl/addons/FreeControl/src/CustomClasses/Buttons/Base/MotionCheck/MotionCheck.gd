# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MotionCheck extends Control
## Checks for motion of the mouse or touch input after a press.

#region Signals
## Emited when check has started (mouse or touch is pressed).
signal start_check
## Emited when check has ended (mouse or touch is released or distance limit has exceeded).
signal end_check

## Emited when mouse or touch is released within the distence limit.
signal end_vaild
## Emited when check has ended without mouse or touch being released within the distence limit.
## [br][br]
## Also see [member cancel_when_outside] and [method _pos_check].
signal end_invaild

## Emited when mouse or touch is moved outside the distence limit.
## [br][br]
## Also see [member cancel_when_outside] and [method _pos_check].
signal pos_exceeded
## Emited when the current held state changes.
signal held_state(state : bool)
#endregion


#region External Variables
## If [code]true[/code], the button's held state is released if input moves outside of
## bounds.
## [br][br]
## Also see [member cancel_when_outside] and [method _pos_check].
@export var release_when_outside : bool = false:
	set(val):
		if release_when_outside != val:
			release_when_outside = val
## If [code]true[/code], then the check will end when mouse or touch is moved outside the distence limit.
## [br][br]
## Also see [member release_when_outside] and [method _pos_check].
@export var cancel_when_outside : bool = false:
	set(val):
		if cancel_when_outside != val:
			cancel_when_outside = val
## If [code]true[/code], then this node does not accept input.
@export var disabled : bool:
	set(val):
		if disabled != val:
			disabled = val
			if val:
				force_release()
#endregion


#region Private Variables
var _checking : bool = false
var _holding : bool = false
#endregion


#region Private Virtual Methods
func _init() -> void:
	mouse_filter = MOUSE_FILTER_PASS
func _property_can_revert(property: StringName) -> bool:
	if property == "mouse_filter":
		return mouse_filter == MOUSE_FILTER_PASS
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property == "mouse_filter":
		return MOUSE_FILTER_PASS
	return null

func _gui_input(event: InputEvent) -> void:
	if disabled: return
	
	if event is InputEventMouseButton || event is InputEventScreenTouch:
		if event.pressed:
			if !_checking && get_global_rect().has_point(event.position):
				_on_check_start(event)
				
				_checking = true
				
				held_state.emit(true)
				start_check.emit()
		elif _checking:
			_on_check_release(event)
			
			_checking = false
			if !_holding:
				held_state.emit(false)
			else:
				_holding = false
			
			if _pos_check(event.position):
				_vaild_end()
			else:
				_invaild_end()
		if mouse_filter == MOUSE_FILTER_STOP: accept_event()
	
	if _checking:
		if event is InputEventMouseMotion || event is InputEventScreenDrag:
			if _holding:
				if _pos_check(event.position):
					held_state.emit(true)
					_checking = true
					_holding = false
				return
			
			if !_pos_check(event.position):
				pos_exceeded.emit()
				if release_when_outside:
					held_state.emit(false)
					_holding = true
				
				if cancel_when_outside:
					_on_check_exceeded(event)
					_holding = false
					_checking = false
					
					_invaild_end()
					return
		
			if mouse_filter == MOUSE_FILTER_STOP:
				accept_event()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EXIT_TREE:
			force_release()
#endregion


#region Custom Virtual Methods
## A virtual method that should be overloaded. Returns [code]true[/code] if [param pos] is
## within the distance limit. [code]false[/code] otherwise.
func _pos_check(pos : Vector2) -> bool:
	return false
## A virtual method that should be overloaded. This is called when an input starts a
## check.
func _on_check_start(event: InputEvent) -> void:
	pass
## A virtual method that should be overloaded. This is called when an input releases a
## check.
func _on_check_release(event: InputEvent) -> void:
	pass
## A virtual method that should be overloaded. This is called when an input exceeds a
## check.
## [br][br]
## Also see [method _pos_check].
func _on_check_exceeded(event: InputEvent) -> void:
	pass 
#endregion


#region Private Methods
func _invaild_end() -> void:
	end_invaild.emit()
	end_check.emit()
func _vaild_end() -> void:
	end_vaild.emit()
	end_check.emit()
#endregion


#region Public Methods
## Forcibly stops this node's check.
func force_release() -> void:
	if _holding:
		held_state.emit(false)
		_holding = false
	if _checking:
		_invaild_end()
		_checking = false
## Returns if this node is currently checking a mouse or touch press.
func is_checking() -> bool: return _checking
## Returns if mouse or touch is being held (mouse or touch outside of limit without being released).
## [br][br]
## Also see [method force_release].
func is_held() -> bool: return _holding
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
