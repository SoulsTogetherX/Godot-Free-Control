# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name StyleTransitionContainer extends Container
## A [Container] node that add a [StyleTransitionPanel] node as the background.


#region External Variables
@export_group("Appearence Override")
## The stylebox used by [StyleTransitionPanel].
@export var background : StyleBox:
	set(val):
		if val == background:
			return
		background = val
		
		if !_panel:
			return
		if val:
			_panel.add_theme_stylebox_override("panel", val)
			return
		_panel.remove_theme_stylebox_override("panel")

@export_group("Colors Override")
## The colors to animate between.
@export var colors : PackedColorArray:
	set(val):
		if val == colors:
			return
		colors = val
		
		if _panel:
			_panel.colors = colors

## The index of currently used color from [member colors].
## This member is [code]-1[/code] if [member colors] is empty.
@export var focused_color : int:
	set(val):
		if val == focused_color:
			return
		focused_color = val
		
		if _panel:
			_panel.focused_color = val

@export_group("Tween Override")
## The duration of color animations.
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var duration : float = 0.2:
	set(val):
		val = maxf(0.001, val)
		if val == duration:
			return
		duration = val
		
		if _panel:
			_panel.duration = val
## The [enum Tween.EaseType] of color animations.
@export var ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if val == ease_type:
			return
		ease_type = val
		
		if _panel:
			_panel.ease_type = val
## The [enum Tween.TransitionType] of color animations.
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC:
	set(val):
		if val == transition_type:
			return
		transition_type = val
		
		if _panel:
			_panel.transition_type = val
## If [code]true[/code] animations can be interupted midway. Otherwise, any change in the [param focused_color]
## will be queued to be reflected after any currently running animation.
@export var can_cancle : bool = true:
	set(val):
		if val == can_cancle:
			return
		can_cancle = val
		
		if _panel:
			_panel.can_cancle = val
#endregion


#region Private Variables
var _panel : StyleTransitionPanel
#endregion



#region Private Virtual Methods
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
			_handle_ready()
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()
#endregion


#region Private Methods (Componet Manager)
func _handle_ready() -> void:
	_panel = StyleTransitionPanel.new()
	add_child(_panel, false, Node.INTERNAL_MODE_FRONT)
	
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	_panel.can_cancle = can_cancle
	_panel.transition_type = transition_type
	_panel.ease_type = ease_type
	_panel.duration = duration
	_panel.focused_color = focused_color
	_panel.colors = colors
	
	if background:
		_panel.add_theme_stylebox_override("panel", background)
		return
	background = _panel.get_theme_stylebox("panel")
#endregion


#region Private Methods (Helper)
func _sort_children() -> void:
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
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
	if _panel:
		_panel.set_color(color)
## Sets the current color index. Performing this will ignore any animation and instantly set the color.
## [br][br]
## Also see: [member focused_color].
func force_color(color: int) -> void:
	if _panel:
		_panel.force_color(color)

## Gets the current color attributed to the current color index.
func get_current_color() -> Color:
	if _panel:
		return _panel.get_current_color()
	return Color.BLACK

## An async method that awaits until the panel's color finished changing.
## If the panel's color isn't changing, then this immediately returns.
func await_color_change() -> void:
	if _panel:
		await _panel.await_color_change()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
