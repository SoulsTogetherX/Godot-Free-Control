# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name StyleTransitionContainer extends Container



@export_group("Appearence Override")
@export var background : StyleBox:
	set(val):
		_panel.add_theme_stylebox_override("panel", val)
		background = val

@export_group("Colors Override")
@export var colors : PackedColorArray = [
	Color.WEB_GRAY,
	Color.DIM_GRAY
]:
	set(val):
		_panel.colors = val
		colors = val
			
@export var focused_color : int:
	set(val):
		_panel.focused_color = val
		focused_color = val

@export_group("Tween Override")
@export var transitionTime : float = 0.2:
	set(val):
		_panel.transitionTime = val
		transitionTime = val
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_OUT_IN:
	set(val):
		_panel.easeType = val
		easeType = val
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC:
	set(val):
		_panel.transition = val
		transition = val
@export var can_cancle : bool = true:
	set(val):
		_panel.can_cancle = val
		can_cancle = val

var _panel : StyleTransitionPanel



func set_color(color: int) -> void:
	if !_panel: return
	_panel.set_color(color)
func force_color(color: int) -> void:
	if !_panel: return
	_panel.force_color(color)

func get_current_color() -> Color:
	if !_panel: return Color.BLACK
	return _panel.get_current_color()



func _init() -> void:
	_panel = StyleTransitionPanel.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)
	move_child(_panel, 0)
	
	if !background:
		background = _panel.get_theme_stylebox("panel")
	
	sort_children.connect(_handle_children)
func _property_can_revert(property: StringName) -> bool:
	if property == "colors":
		return colors.size() == 2 && colors[0] == Color.WEB_GRAY && colors[1] == Color.DIM_GRAY
	return false

func _handle_children() -> void:
	for child in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
func _get_minimum_size() -> Vector2:
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control:
			min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
