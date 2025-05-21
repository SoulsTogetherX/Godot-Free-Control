# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatedSwitch extends BaseButton



@export_group("Redirect")
@export var vertical : bool = false:
	set(val):
		if vertical != val:
			vertical = val
			force_state(button_pressed)
@export var flip : bool = false:
	set(val):
		if flip != val:
			flip = val
			force_state(button_pressed)

@export_group("Size")
@export var switch_size : Vector2 = Vector2(100, 50):
	set(val):
		if switch_size != val:
			switch_size = val
			_handle_resize()
			update_minimum_size()
@export var knob_size : Vector2 = Vector2(40, 40):
	set(val):
		if knob_size != val:
			knob_size = val
			_handle_resize()
			update_minimum_size()
@export var knob_overextend : float = 10:
	set(val):
		if knob_overextend != val:
			knob_overextend = val
			_handle_resize()
			update_minimum_size()

@export_group("Display")
@export var knob_bg : StyleBox:
	set(val):
		if knob_bg != val:
			knob_bg = val
			
			if knob_bg:
				_knob.add_theme_stylebox_override("panel", knob_bg)
			else:
				_knob.remove_theme_stylebox_override("panel")
@export var switch_bg : StyleBox:
	set(val):
		if switch_bg != val:
			switch_bg = val
			
			if knob_bg:
				_bg.add_theme_stylebox_override("panel", switch_bg)
			else:
				_knob.remove_theme_stylebox_override("panel")

@export_group("Animation Properties")
@export var knob_ease : Tween.EaseType
@export var knob_transition : Tween.TransitionType
@export_range(0.001, 0.5, 0.001, "or_greater") var knob_duration : float = 0.25



var _knob : Panel
var _bg : Panel

var _animate_tween : Tween


func force_state(knob_state : bool) -> void:
	_kill_animation()
	button_pressed = knob_state
	_position_knob(int(knob_state))
func toggle_state(knob_state : bool) -> void:
	button_pressed = knob_state
	await _animate_knob(knob_state)


func _kill_animation() -> void:
	if _animate_tween && _animate_tween.is_running():
		_animate_tween.finished.emit()
		_animate_tween.kill()
func _animate_knob(knob_state : bool) -> void:
	_kill_animation()
	
	_animate_tween = create_tween()
	_animate_tween.set_ease(knob_ease)
	_animate_tween.set_trans(knob_transition)
	_animate_tween.tween_method(
		_position_knob,
		1.0 - float(knob_state),
		0.0 + float(knob_state),
		knob_duration
	)
	await _animate_tween.finished
func _position_knob(delta : float) -> void:
	if flip:
		delta = 1.0 - delta
	
	var offset : Vector2
	var delta_v : Vector2
	if vertical:
		offset = Vector2(0.0, knob_overextend)
		delta_v = Vector2(0.5, delta)
	else:
		offset = Vector2(knob_overextend, 0.0)
		delta_v = Vector2(delta, 0.5)
	
	_knob.position = (
		(switch_size - knob_size + offset + offset) * delta_v # Size
		+ (_bg.position - offset) # Position
	)



func _init() -> void:
	toggle_mode = true
	_bg = Panel.new()
	_knob = Panel.new()
	
	add_child(_bg)
	add_child(_knob)
	
	resized.connect(_handle_resize)
	toggled.connect(toggle_state)
	_handle_resize()
func _handle_resize() -> void:
	_bg.position = (size - switch_size) * 0.5
	_bg.size = switch_size
	
	_knob.size = knob_size
	force_state(button_pressed)
func _get_minimum_size() -> Vector2:
	return knob_size.max(switch_size + Vector2(max(0, knob_overextend) * 2, 0))
func _validate_property(property: Dictionary) -> void:
	if property.name == "toggle_mode":
		property.usage &= ~PROPERTY_USAGE_EDITOR

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
