# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name ModulateTransitionButton  extends ModulateTransitionContainer


signal release_state(toggle : bool)
signal press_vaild
signal press_start
signal press_end


var _button : HoldButton



@export_group("Toggleable")
@export var pressed : bool:
	set(val):
		if pressed != val:
			pressed = val
			_set_button_color(val)
var _disabled : bool:
	set = _set_disabled
@export var disabled : bool:
	set(val):
		if disabled != val:
			disabled = val
			_set_disabled(_disabled)
@export var toggle_mode : bool:
	set(val):
		if toggle_mode != val:
			toggle_mode = val
			pressed = false
			notify_property_list_changed()
			
			if _button: _button.toggle_mode = val
@export var load_affected : bool = true:
	set(val):
		if load_affected != val:
			load_affected = val

@export_group("Alpha")
@export var normal_color : Color = Color(1.0, 1.0, 1.0, 1.0):
	set(val):
		if normal_color != val:
			normal_color = val
			colors[0] = val
			force_color(focused_color)
@export var focus_color : Color = Color(1.0, 1.0, 1.0, 0.75):
	set(val):
		if focus_color != val:
			focus_color = val
			colors[1] = val
			force_color(focused_color)
@export var disabled_color : Color = Color(1.0, 1.0, 1.0, 0.5):
	set(val):
		if disabled_color != val:
			disabled_color = val
			colors[2] = val
			force_color(focused_color)


func is_held() -> bool: return _button && _button.is_held()
func force_release() -> void: if _button: _button.force_release()

func _init() -> void:
	super()
	colors = [normal_color, focus_color, disabled_color]
	
	_button = HoldButton.new()
	add_child(_button)
	_button.move_to_front()
	
	if !Engine.is_editor_hint():
		_button.pressed_state.connect(_set_button_color)
		_button.release_state.connect(_emit_vaild_release)
		
		_button.press_start.connect(press_start.emit)
		_button.press_end.connect(press_end.emit)
		_button.press_released_vaild.connect(press_vaild.emit)
	
	_button.mouse_filter = mouse_filter
	_button.mouse_force_pass_scroll_events = mouse_force_pass_scroll_events
	_button.mouse_default_cursor_shape = mouse_default_cursor_shape
	
	_button.toggle_mode = toggle_mode
	_button.button_pressed_state = pressed
	_button.disabled = _disabled
func _ready() -> void:
	if !Engine.is_editor_hint():
		child_order_changed.connect(_button.move_to_front, CONNECT_DEFERRED)
func _validate_property(property: Dictionary) -> void:
	match property.name:
		"pressed":
			if !toggle_mode:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"focused_alpha", "alphas":
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

func _set_disabled(val : bool) -> void:
	_disabled = val || disabled
	
	_set_button_color(pressed)
	if _button:
		_button.disabled = _disabled
func _set_button_color(val : bool) -> void:
	if _disabled: set_color(2)
	else: set_color(int(val))

func _emit_vaild_release(release : bool) -> void:
	_set_button_color(release)
	release_state.emit(release)

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
