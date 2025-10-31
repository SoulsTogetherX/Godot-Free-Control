# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name StyleTransitionPanel extends Panel
## A [Panel] node with changable that allows easy [member CanvasItem.self_modulate] animation between colors.

#region External Variables
@export_group("Colors Override")
## The colors to animate between.
@export var colors : PackedColorArray:
	set(val):
		if colors != val:
			colors = val
			focused_color = focused_color
		force_color(_focused_color)
var _focused_color : int = 0
## The index of currently used color from [member colors].
## This member is [code]-1[/code] if [member colors] is empty.
@export var focused_color : int:
	get: return _focused_color
	set(val):
		if colors.size() == 0:
			_focused_color = -1
			return
		
		val = clampi(val, 0, colors.size() - 1)
		if _focused_color != val:
			_focused_color = val
			_on_set_color()

@export_group("Tween Override")
## The duration of color animations.
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var duration : float = 0.2:
	set(val):
		val = maxf(0.001, val)
		if val != duration:
			duration = val
## The [enum Tween.EaseType] of color animations.
@export var ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
## The [enum Tween.TransitionType] of color animations.
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC
## If [code]true[/code] animations can be interupted midway. Otherwise, any change in the [param focused_color]
## will be queued to be reflected after any currently running animation.
@export var can_cancle : bool = true
#endregion


#region Private Variables
var _color_tween : Tween = null
var _current_focused_color : int
#endregion


#region Private Virtual Methods
func _init() -> void:
	_current_focused_color = _focused_color
	_safe_base_set_background()

func _property_can_revert(property: StringName) -> bool:
	if property == "colors":
		return colors.size() == 2 && colors[0] == Color.WEB_GRAY && colors[1] == Color.DIM_GRAY
	return false
#endregion


#region Private Methods
func _safe_base_set_background() -> void:
	if has_theme_stylebox_override("panel"):
		return
	
	var background = StyleBoxFlat.new()
	background.resource_local_to_scene = true
	background.bg_color = Color.WHITE
	add_theme_stylebox_override("panel", background)

func _kill_color_tween() -> void:
	if _color_tween && _color_tween.is_running():
		_color_tween.finished.emit()
		_color_tween.kill()
func _on_set_color():
	if _focused_color == _current_focused_color:
		return
	if can_cancle:
		_kill_color_tween()
	elif _color_tween && _color_tween.is_running():
		return
	_current_focused_color = _focused_color
	
	_safe_base_set_background()
	_color_tween = create_tween()
	_color_tween.set_ease(ease_type)
	_color_tween.set_trans(transition_type)
	_color_tween.tween_property(self, "self_modulate", get_current_color(), duration)
	_color_tween.finished.connect(_on_set_color, CONNECT_ONE_SHOT)
#endregion


#region Public Methods
## Returns if the given color index is vaild.
func is_vaild_color(color: int) -> bool:
	return 0 <= color && color < colors.size() 
## Sets the current color index.
## [br][br]
## Also see: [member focused_color].
func set_color(color: int) -> void:
	if !is_vaild_color(color):
		return
	focused_color = color
## Sets the current color index. Performing this will ignore any animation and instantly set the color.
## [br][br]
## Also see: [member focused_color].
func force_color(color: int) -> void:
	if !is_vaild_color(color):
		return
	
	if _color_tween && _color_tween.is_running():
		if !can_cancle:
			return
		_kill_color_tween()
	_current_focused_color = color
	_focused_color = color
	_safe_base_set_background()
	self_modulate = get_current_color()

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if _focused_color == -1:
		return Color.BLACK
	return colors[_focused_color]

## An async method that awaits until the color finished changing.
## If the color isn't changing, then this immediately returns.
func await_color_change() -> void:
	if _color_tween && _color_tween.is_running():
		await _color_tween.finished
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
