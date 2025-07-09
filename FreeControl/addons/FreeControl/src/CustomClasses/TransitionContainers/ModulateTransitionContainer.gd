# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name ModulateTransitionContainer extends Container
## A [Control] node with changable that allows easy [member CanvasItem.modulate] animation between colors.

#region External Variables
@export_group("Alpha Override")
## The colors to animate between.
@export var colors : PackedColorArray = [Color.WHITE, Color(1.0, 1.0, 1.0, 0.5)]:
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
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var transitionTime : float = 0.2
## The [Tween.EaseType] of color animations.
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_OUT_IN
## The [Tween.TransitionType] of color animations.
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC
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
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control:
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
func _on_set_color():
	if _focused_color == _current_focused_color:
		return
	if can_cancle:
		if _color_tween: _color_tween.kill()
	elif _color_tween && _color_tween.is_running():
		return
	_current_focused_color = _focused_color
		
	_color_tween = create_tween()
	_color_tween.tween_property(
		self,
		"self_modulate" if modulate_self else "modulate", 
		get_current_color(),
		transitionTime
	)
	_color_tween.finished.connect(_on_set_color, CONNECT_ONE_SHOT)

func _sort_children() -> void:
	for child in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
#endregion


#region Public Methods
## Sets the current color index.
## [br][br]
## Also see: [member focused_color].
func set_color(color: int) -> void:
	focused_color = color
## Sets the current color index. Performing this will ignore any animation and instantly set the color.
## [br][br]
## Also see: [member focused_color].
func force_color(color: int) -> void:
	if _color_tween && _color_tween.is_running():
		if !can_cancle: return
		_color_tween.kill()
	_current_focused_color = color
	_focused_color = color
	modulate = colors[color]

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if _focused_color == -1: return 1
	return colors[_focused_color]
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
