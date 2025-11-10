# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name ModulateTransitionContainer extends Container
## A [Control] node with changable that allows easy [member CanvasItem.modulate] animation between colors.

#region External Variables
@export_group("Alpha Override")
## The colors to animate between.
@export var colors : PackedColorArray = [
	Color.WHITE,
	Color(1.0, 1.0, 1.0, 0.5)
]:
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
## If [code]true[/code] this node will only animate over [member CanvasItem.self_modulate]. Otherwise,
## it will animate over [member CanvasItem.modulate].
@export var modulate_self : bool = false

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
var _color_tween : Tween
var _current_focused_color : int
#endregion


#region Private Virtual Methods
func _init() -> void:
	_current_focused_color = _focused_color
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
			min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _property_can_revert(property: StringName) -> bool:
	if property == "colors":
		return colors.size() == 2 && colors[0] == Color.WHITE && colors[1] == Color(1.0, 1.0, 1.0, 0.5)
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()
#endregion


#region Private Methods
func _kill_color_tween() -> void:
	if _color_tween && _color_tween.is_running():
		_color_tween.kill()
func _on_set_color():
	if _focused_color == _current_focused_color:
		return
	if can_cancle:
		_kill_color_tween()
	elif _color_tween && _color_tween.is_running():
		return
	_current_focused_color = _focused_color
	
	_color_tween = create_tween()
	_color_tween.set_ease(ease_type)
	_color_tween.set_trans(transition_type)
	_color_tween.tween_property(
		self,
		"self_modulate" if modulate_self else "modulate", 
		get_current_color(),
		duration
	)
	_color_tween.finished.connect(_on_set_color, CONNECT_ONE_SHOT)

func _sort_children() -> void:
	for child : Node in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
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
	modulate = colors[color]

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if _focused_color == -1:
		return 1
	return colors[_focused_color]

## An async method that awaits until the color finished changing.
## If the color isn't changing, then this immediately returns.
func await_color_change() -> void:
	if _color_tween && _color_tween.is_running():
		await _color_tween.finished
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
