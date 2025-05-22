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
@export var knob_offset : Vector2 = Vector2.ZERO:
	set(val):
		if knob_offset != val:
			knob_offset = val
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
				_switch.add_theme_stylebox_override("panel", switch_bg)
			else:
				_switch.remove_theme_stylebox_override("panel")

@export_group("Colors")
@export_subgroup("Knob")
@export var knob_bg_normal : Color:
	set(val):
		if knob_bg_normal != val:
			knob_bg_normal = val
			
			_kill_color_animation()
			_animate_color(false)
@export var knob_bg_focus : Color:
	set(val):
		if knob_bg_focus != val:
			knob_bg_focus = val
			
			_kill_color_animation()
			_animate_color(false)
@export var knob_bg_disabled : Color:
	set(val):
		if knob_bg_disabled != val:
			knob_bg_disabled = val
			
			_kill_color_animation()
			_animate_color(false)

@export_subgroup("Switch")
@export var switch_bg_normal : Color:
	set(val):
		if switch_bg_normal != val:
			switch_bg_normal = val
			
			_kill_color_animation()
			_animate_color(false)
@export var switch_bg_focus : Color:
	set(val):
		if switch_bg_focus != val:
			switch_bg_focus = val
			
			_kill_color_animation()
			_animate_color(false)
@export var switch_bg_disabled : Color:
	set(val):
		if switch_bg_disabled != val:
			switch_bg_disabled = val
			
			_kill_color_animation()
			_animate_color(false)


@export_group("Animation Properties")
@export_subgroup("Main")
@export var main_ease : Tween.EaseType
@export var main_transition : Tween.TransitionType
@export_range(0.001, 0.5, 0.001, "or_greater") var main_duration : float = 0.15

@export_subgroup("Knob Color")
@export var animate_knob_color : bool = true
@export var knob_color_ease : Tween.EaseType
@export var knob_color_transition : Tween.TransitionType
@export_range(0.001, 0.5, 0.001, "or_greater") var knob_color_duration : float = 0.1

@export_subgroup("Switch Color")
@export var animate_switch_color : bool = true
@export var switch_color_ease : Tween.EaseType
@export var switch_color_transition : Tween.TransitionType
@export_range(0.001, 0.5, 0.001, "or_greater") var switch_color_duration : float = 0.1



var _knob : Panel
var _switch : Panel

var _main_animate_tween : Tween
var _knob_color_animate_tween : Tween
var _switch_color_animate_tween : Tween



func force_state(knob_state : bool) -> void:
	_handle_animations(false, knob_state)
func toggle_state(knob_state : bool) -> void:
	_handle_animations(true, knob_state)


func get_knob_color() -> Color:
	if disabled:
		return knob_bg_disabled
	return knob_bg_focus if button_pressed else knob_bg_normal
func get_switch_color() -> Color:
	if disabled:
		return switch_bg_disabled
	return switch_bg_focus if button_pressed else switch_bg_normal



func _kill_main_animation() -> void:
	if _main_animate_tween && _main_animate_tween.is_running():
		_main_animate_tween.kill()
func _kill_color_animation() -> void:
	if _knob_color_animate_tween && _knob_color_animate_tween.is_running():
		_knob_color_animate_tween.kill()
	if _switch_color_animate_tween && _switch_color_animate_tween.is_running():
		_main_animate_tween.kill()


func _handle_animations(animate : bool, knob_state : bool) -> void:
	_kill_main_animation()
	_kill_color_animation()
	button_pressed = knob_state
	
	if animate:
		_animate_knob(knob_state)
		_animate_color(true)
		return
	
	_position_knob(float(knob_state))
	_animate_color(false)

func _animate_knob(knob_state : bool) -> void:
	_main_animate_tween = create_tween()
	_main_animate_tween.set_ease(main_ease)
	_main_animate_tween.set_trans(main_transition)
	_main_animate_tween.tween_method(
		_position_knob,
		1.0 - float(knob_state),
		0.0 + float(knob_state),
		main_duration
	)
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
		+ (_switch.position - offset) # Position
		+ knob_offset # Offset
	)
func _animate_color(animate : bool = false) -> void:
	if animate && animate_knob_color:
		_knob_color_animate_tween = create_tween()
		_knob_color_animate_tween.set_ease(knob_color_ease)
		_knob_color_animate_tween.set_trans(knob_color_transition)
		_knob_color_animate_tween.tween_property(
			_knob,
			"self_modulate",
			get_knob_color(),
			knob_color_duration
		)
	else:
		_knob.self_modulate = get_knob_color()
	
	if animate && animate_switch_color:
		_switch_color_animate_tween = create_tween()
		_switch_color_animate_tween.set_ease(switch_color_ease)
		_switch_color_animate_tween.set_trans(switch_color_transition)
		_switch_color_animate_tween.tween_property(
			_switch,
			"self_modulate",
			get_switch_color(),
			switch_color_duration
		)
	else:
		_switch.self_modulate = get_switch_color()



func _init() -> void:
	toggle_mode = true
	_switch = Panel.new()
	_knob = Panel.new()
	
	add_child(_switch)
	add_child(_knob)
	
	resized.connect(_handle_resize)
	toggled.connect(toggle_state)
func _handle_resize() -> void:
	_switch.position = (size - switch_size) * 0.5
	_switch.size = switch_size
	
	_knob.size = knob_size
	force_state(button_pressed)

func _get_minimum_size() -> Vector2:
	return (knob_size + (knob_offset.abs() * 0.5)).max(switch_size + Vector2(max(0, knob_overextend) * 2, 0))
func _validate_property(property: Dictionary) -> void:
	if property.name == "toggle_mode":
		property.usage &= ~PROPERTY_USAGE_EDITOR

func _set(property: StringName, value: Variant) -> bool:
	if property == "disabled":
		disabled = value
		_animate_color()
		return true
	return false

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
