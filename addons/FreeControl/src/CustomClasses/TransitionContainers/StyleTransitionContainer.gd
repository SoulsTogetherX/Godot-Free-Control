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
			if val:
				_panel.add_theme_stylebox_override("panel", val)
			else:
				_panel.remove_theme_stylebox_override("panel")
			
			background = val
		elif background != val:
			background = val

@export_group("Colors Override")
## The colors to animate between.
@export var colors : PackedColorArray:
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
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var duration : float = 0.2:
	set(val):
		val = maxf(0.001, val)
		if _panel:
			_panel.duration = val
			duration = val
		elif duration != val:
			duration = val
## The [enum Tween.EaseType] of color animations.
@export var ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if _panel:
			_panel.ease_type = val
			ease_type = val
		elif ease_type != val:
			ease_type = val
## The [enum Tween.TransitionType] of color animations.
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC:
	set(val):
		if _panel:
			_panel.transition_type = val
			transition_type = val
		elif transition_type != val:
			transition_type = val
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
		return colors.size() == 2 && colors[0] == Color.WEB_GRAY && colors[1] == Color.DIM_GRAY
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY:
			if background:
				_panel.add_theme_stylebox_override("panel", background)
				return
			background = _panel.get_theme_stylebox("panel")
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()
#endregion


#region Private Methods
func _sort_children() -> void:
	for child : Node in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
#endregion


#region Public Methods
## Returns if the given color index is vaild.
func is_vaild_color(color: int) -> bool:
	return _panel && _panel.is_vaild_color(color)

## Sets the current color index.
## [br][br]
## Also see: [member focused_color].
func set_color(color: int) -> void:
	if !_panel:
		return
	_panel.set_color(color)
## Sets the current color index. Performing this will ignore any animation and instantly set the color.
## [br][br]
## Also see: [member focused_color].
func force_color(color: int) -> void:
	if !_panel:
		return
	_panel.force_color(color)

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if !_panel:
		return Color.BLACK
	return _panel.get_current_color()

## An async method that awaits until the panel's color finished changing.
## If the panel's color isn't changing, then this immediately returns.
func await_color_change() -> void:
	if _panel:
		await _panel.await_color_change()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
