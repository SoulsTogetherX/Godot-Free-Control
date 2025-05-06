@tool
class_name ColorTransitionContainer extends PanelContainer

@export_group("Appearence Override")
@export var background : StyleBox:
	set(val):
		if val == null:
			background = StyleBoxFlat.new()
			background.resource_local_to_scene = true
			_base_set_background()
			return
		
		background = val
		background.bg_color = get_current_color()
		add_theme_stylebox_override("panel", background)

@export_group("Colors Override")
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
@export var colors : PackedColorArray = [
			Color.WEB_GRAY,
			Color.DIM_GRAY
		]:
	set(val):
		if colors != val:
			colors = val
			focused_color = focused_color
			force_color(_focused_color)

@export_group("Tween Override")
@export var transitionTime : float = 0.2;
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_OUT_IN
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_CIRC
@export var can_cancle : bool = true

var _color_tween : Tween = null;
var _current_focused_color : int

func _ready() -> void:
	_current_focused_color = _focused_color
	focused_color = focused_color
	
	if background == null:
		background = StyleBoxFlat.new()
		background.resource_local_to_scene = true
		_base_set_background()
	resized.connect(_handle_childrend)
func _handle_childrend() -> void:
	for child in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
func _property_can_revert(property: StringName) -> bool:
	if property == "colors":
		return colors.size() == 2 && colors[0] == Color.WEB_GRAY && colors[1] == Color.DIM_GRAY
	return false

func _safe_base_set_background() -> void:
	if !background:
		background = StyleBoxFlat.new()
		background.resource_local_to_scene = true
	if !has_theme_stylebox_override("panel"): _base_set_background()
func _base_set_background() -> void:
	background.bg_color = get_current_color()
	background.resource_local_to_scene = true
	add_theme_stylebox_override("panel", background)

func _on_set_color():
	if _focused_color == _current_focused_color: return
	if can_cancle:
		if _color_tween: _color_tween.kill()
	elif _color_tween && _color_tween.is_running():
		return
	_current_focused_color = _focused_color
		
	_color_tween = create_tween()
	_safe_base_set_background()
	_color_tween.tween_property(
		background,
		"bg_color",
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
	_focused_color = color
	_safe_base_set_background()
	background.bg_color = get_current_color()

func get_current_color() -> Color:
	if _focused_color == -1: return Color.BLACK
	return colors[_focused_color]
