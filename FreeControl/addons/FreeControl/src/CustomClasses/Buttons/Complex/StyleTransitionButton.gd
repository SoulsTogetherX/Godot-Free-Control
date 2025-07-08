# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name StyleTransitionButton extends StyleTransitionContainer
## A button that inherts from [StyleTransitionContainer] and uses [HoldButton] as
## input.

#region Signals
## Emits the state of the button as it is released.
signal release_state(toggle : bool)

## Emits when button is released with all vaild conditions.
signal press_vaild

## Emits when press starts.
signal press_start
## Emits when press ends.
signal press_end
#endregion


#region External Variables
@export_group("Toggleable")
## If [code]true[/code], the button's state is pressed. Means the button is pressed down
## or toggled (if [member toggle_mode] is active). Only works if [member toggle_mode] is
## [code]false[/code].
@export var button_pressed : bool:
	set(val):
		if button_pressed != val:
			button_pressed = val
			_set_button_color(val)
## If [code]true[/code], the button is in [member toggle_mode]. Makes the button
## flip state between pressed and unpressed each time its area is clicked.
@export var toggle_mode : bool:
	set(val):
		if toggle_mode != val:
			toggle_mode = val
			button_pressed = false
			notify_property_list_changed()
			
			if _button: _button.toggle_mode = val
var _disabled : bool:
	set = _set_disabled
## If [code]true[/code], then this node does not accept input.
@export var disabled : bool:
	set(val):
		if disabled != val:
			disabled = val
			_set_disabled(val)

@export_group("Colors")
## The color to modulate to when this node is unfocused.
@export var normal_color : Color = Color(0.525, 0.329, 0.808):
	set(val):
		if normal_color != val:
			normal_color = val
			if is_node_ready(): colors[0] = val
			force_color(focused_color)
## The color to modulate to when this node is focused.
@export var focus_color : Color = Color(0.611, 0.441, 0.886):
	set(val):
		if focus_color != val:
			focus_color = val
			if is_node_ready(): colors[1] = val
			force_color(focused_color)
## The color to modulate to when this node is disabled.
@export var disabled_color : Color = Color(0.318, 0.247, 0.565):
	set(val):
		if disabled_color != val:
			disabled_color = val
			if is_node_ready(): colors[2] = val
			force_color(focused_color)
#endregion


#region Private Variables
var _button : HoldButton
#endregion


#region Private Virtual Methods
func _init() -> void:
	super()
	
	if _button && is_instance_valid(_button):
		_button.queue_free()
	_button = HoldButton.new()
	add_child(_button)
	
	_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button.move_to_front()
	
	if !Engine.is_editor_hint():
		child_order_changed.connect(_button.move_to_front, CONNECT_DEFERRED)
		
		_button.button_state.connect(_set_button_color)
		_button.release_state.connect(_emit_vaild_release)
		
		_button.press_start.connect(press_start.emit)
		_button.press_end.connect(press_end.emit)
		_button.press_vaild.connect(press_vaild.emit)
	
	_button.mouse_filter = mouse_filter
	_button.mouse_force_pass_scroll_events = mouse_force_pass_scroll_events
	_button.mouse_default_cursor_shape = mouse_default_cursor_shape
	
	_button.toggle_mode = toggle_mode
	_button.button_pressed = button_pressed
	_button.disabled = _disabled
func _ready() -> void:
	super()
	colors = [normal_color, focus_color, disabled_color]
	force_color(2 if _disabled else (1 if button_pressed else 0))


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"pressed":
			if !toggle_mode:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"focused_color", "colors":
			property.usage &= ~PROPERTY_USAGE_EDITOR
	
func _set(property: StringName, value: Variant) -> bool:
	if _button:
		match property:
			"mouse_filter":
				_button.mouse_filter = value
			"mouse_force_pass_scroll_events":
				_button.mouse_force_pass_scroll_events = value
			"mouse_default_cursor_shape":
				_button.mouse_default_cursor_shape = value
	return false
func _get(property: StringName) -> Variant:
	if _button:
		match property:
			"mouse_filter":
				return _button.mouse_filter
			"mouse_force_pass_scroll_events":
				return _button.mouse_force_pass_scroll_events
			"mouse_default_cursor_shape":
				return _button.mouse_default_cursor_shape
	return null
#endregion


#region Private Methods
func _set_disabled(val : bool) -> void:
	_disabled = val || disabled
	
	_set_button_color(button_pressed)
	if _button:
		_button.disabled = _disabled
func _set_button_color(val : bool) -> void:
	if _disabled: set_color(2)
	else: set_color(int(val))

func _emit_vaild_release(release : bool) -> void:
	_set_button_color(release)
	release_state.emit(release)
#endregion


#region Public Methods
## Forcibly stops this node's check.
func force_release() -> void:
	if _button: _button.force_release()
## Returns if mouse or touch is being held (mouse or touch outside of limit without being released).
func is_held() -> bool:
	return _button && _button.is_held()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
