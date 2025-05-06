@tool
class_name ModulateTransitionContainer extends MarginContainer

var _color_tween : Tween = null
var _current_focused_color : int

@export_group("Alpha Override")
var _focused_color : int = 0
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
@export var colors : PackedColorArray = [Color.WHITE, Color(1.0, 1.0, 1.0, 0.5)]:
	set(val):
		if colors != val:
			colors = val
			focused_color = focused_color
			force_color(_focused_color)
@export var modulate_self : bool = false:
	set(val):
		if modulate_self != val:
			modulate_self = val
			force_color(_focused_color)

@export_group("Tween Override")
@export var transitionTime : float = 0.2;
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_OUT_IN
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC
@export var can_cancle : bool = true

func _ready() -> void:
	_current_focused_color = _focused_color
	focused_color = focused_color
	
	modulate = colors[_focused_color]
	resized.connect(_handle_childrend)
func _handle_childrend() -> void:
	for child in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
func _get_minimum_size() -> Vector2:
	var max_min_child_size : Vector2 = Vector2.ZERO;
	for c in get_children(true):
		if c is Control:
			max_min_child_size = max_min_child_size.max(c.get_minimum_size())
	return max_min_child_size


func _on_set_color():
	if _focused_color == _current_focused_color: return
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

func set_color(color: int) -> void:
	focused_color = color
func force_color(color: int) -> void:
	if _color_tween && _color_tween.is_running():
		if !can_cancle: return
		_color_tween.kill()
	_current_focused_color = color
	modulate = colors[color]

func get_current_color() -> Color:
	if _focused_color == -1: return 1
	return colors[_focused_color]
