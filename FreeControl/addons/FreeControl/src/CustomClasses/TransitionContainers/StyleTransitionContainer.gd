# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name StyleTransitionContainer extends Container
## A [Container] node that add a [StyleTransitionPanel] node as the background.

#region External Variables
@export_group("Appearence Override")
## The stylebox used by [StyleTransitionPanel].
@export var background : StyleBox:
	set(val):
		if _panel:
			_panel.add_theme_stylebox_override("panel", val)
			background = val
		elif background != val:
			background = val

@export_group("Colors Override")
## The colors to animate between.
@export var colors : PackedColorArray = [
	Color.WEB_GRAY,
	Color.DIM_GRAY
]:
	set(val):
		if _panel:
			_panel.colors = val
			colors = val
		elif colors != val:
			colors = val

## The index of currently used color from [member colors].
## This member is [code]-1[/code] if [member colors] is empty.
@export var focused_color : int:
	set(val):
		if _panel:
			_panel.focused_color = val
			focused_color = val
		elif focused_color != val:
			focused_color = val

@export_group("Tween Override")
## The duration of color animations.
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var transitionTime : float = 0.2:
	set(val):
		if _panel:
			_panel.transitionTime = val
			transitionTime = val
		elif transitionTime != val:
			transitionTime = val
## The [Tween.EaseType] of color animations.
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_OUT_IN:
	set(val):
		if _panel:
			_panel.easeType = val
			easeType = val
		elif easeType != val:
			easeType = val
## The [Tween.TransitionType] of color animations.
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC:
	set(val):
		if _panel:
			_panel.transition = val
			transition = val
		elif transition != val:
			transition = val
## If [code]true[/code] animations can be interupted midway. Otherwise, any change in the [param focused_color]
## will be queued to be reflected after any currently running animation.
@export var can_cancle : bool = true:
	set(val):
		if _panel:
			_panel.can_cancle = val
			can_cancle = val
		elif can_cancle != val:
			can_cancle = val
#endregion


#region Private Variables
var _panel : StyleTransitionPanel
#endregion


#region Private Virtual Methods
func _init() -> void:
	_panel = StyleTransitionPanel.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)
func _ready() -> void:
	if background:
		_panel.add_theme_stylebox_override("panel", background)
		return
	background = _panel.get_theme_stylebox("panel")

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
		return colors.size() == 2 && colors[0] == Color.WEB_GRAY && colors[1] == Color.DIM_GRAY
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()
#endregion


#region Private Methods
func _sort_children() -> void:
	for child in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
#endregion


#region Public Methods
## Sets the current color index.
## [br][br]
## Also see: [member focused_color].
func set_color(color: int) -> void:
	if !_panel: return
	_panel.set_color(color)
## Sets the current color index. Performing this will ignore any animation and instantly set the color.
## [br][br]
## Also see: [member focused_color].
func force_color(color: int) -> void:
	if !_panel: return
	_panel.force_color(color)

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if !_panel: return Color.BLACK
	return _panel.get_current_color()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
