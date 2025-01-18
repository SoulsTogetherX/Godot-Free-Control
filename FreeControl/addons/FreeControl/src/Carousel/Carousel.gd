@tool
class_name Carousel extends Container

enum DRAG_LIMIT {
	None = 0b00,
	Limits = 0b01,
	Item = 0b10,
	Both = 0b11
}

@export_group("Carousel Options")
@export var starting_index : int = 0:
	set(val):
		if Engine.is_editor_hint():
			val = _loop_index(val)
		if starting_index != val:
			starting_index = val
			_index = val
			if Engine.is_editor_hint():
				goToIndex(val, false)
@export var item_size : Vector2 = Vector2(200, 200):
	set(val):
		if item_size != val:
			item_size = val
			_settup_children()
			
			if is_node_ready(): goToIndex(_index, false)
@export var vertical : bool = false:
	set(val):
		if vertical != val:
			vertical = val
			_settup_children()
			
			if is_node_ready(): goToIndex(_index, false)

@export_group("Loop Options")
@export var allow_loop : bool
@export var display_loop : bool
@export var display_range : int = 0

@export_group("Snap")
@export var paging_enabled : bool
@export var enable_snap : bool:
	set(val):
		if val != enable_snap:
			enable_snap = val
			
			if val && is_node_ready(): _create_animation(getExactIndex(), true)

@export_group("Animation Options")
@export_subgroup("Carousel")
@export_range(0.001, 2.0, 0.001, "or_greater") var carousel_duration : float = 0.4
@export var carousel_transtion_type : Tween.TransitionType
@export var carousel_ease_type : Tween.EaseType

@export_subgroup("Snap")
@export_range(0.001, 2.0, 0.001, "or_greater") var snap_duration : float = 0.2
@export var snap_transtion_type : Tween.TransitionType
@export var snap_ease_type : Tween.EaseType

@export_group("Drag")
@export var can_drag : bool = true:
	set(val):
		if val != can_drag:
			can_drag = val
			if !val:
				_drag_scroll_value = 0
				_adjust_children()
@export var drag_limit : int = 0:
	set(val):
		val = max(0, val)
		if val != drag_limit: drag_limit = val
@export var border_limit : int = 0:
	set(val):
		val = max(0, val)
		if val != border_limit:
			border_limit = val
			_adjust_children()

var _scroll_value : int
var _drag_scroll_value : int

var _item_count : int = 0
var _index : int

var _is_dragging = false: set = _set_drag
var _scroll_tween : Tween

var _child_rects : Array[Rect2] = []

# var autoPlay
# var autoPlayReverse
# var autoPlayInterval

# var mode

# var parallaxScrollingOffset
# var parallaxScrollingScale

func _set_drag(val) -> void:
	if _is_dragging != val:
		_is_dragging = val
		
		if val:
			_kill_animation()
		else:
			if enable_snap:
				_create_animation(getExactIndex(), true)

func _ready() -> void:
	if !sort_children.is_connected(_settup_children):
		sort_children.connect(_settup_children)
	
	_settup_children()
	get_tree().process_frame.connect(goToIndex.bind(starting_index, false), CONNECT_ONE_SHOT)
func _gui_input(event: InputEvent) -> void:
	if !can_drag: return
	
	if event is InputEventScreenDrag && event.index == 0:
		_is_dragging = true
		
		if vertical: _drag_scroll_value += event.relative.y
		else: _drag_scroll_value += event.relative.x
		
		if drag_limit > 0:
			_drag_scroll_value = clampi(_drag_scroll_value, -drag_limit, drag_limit)
		
		var exact := getExactIndex(true)
		#if paging_enabled && exact == _index: return
		_index = exact
		_adjust_children()
	elif event is InputEventScreenTouch && !event.pressed:
		_scroll_value = _get_adjusted_scroll()
		_drag_scroll_value = 0
		_is_dragging = false

func prev(animation : bool = true) -> void:
	goToIndex(_index - 1, animation)
func next(animation : bool = true) -> void:
	goToIndex(_index + 1, animation)

func goToIndex(idx : int, animation : bool = true) -> void:
	_index = _loop_index(idx)
	
	if animation: _create_animation(_index, false)
	else:
		_kill_animation()
		_scroll_value = -(item_size.y if vertical else item_size.x) * _index
		_adjust_children()

func getCurrentIndex() -> int:
	return _index
func getExactIndex(with_drag : bool = false) -> int:
	var scroll : int = _scroll_value
	if with_drag: scroll += _drag_scroll_value
	
	var calculated := -floori((float(scroll) / float(_get_relevant_axis())) + 0.5)
	calculated = clampi(calculated, 0, _item_count - 1)
	
	return calculated

func _get_relevant_axis() -> int:
	return item_size.y if vertical else item_size.x
func _get_adjusted_scroll() -> int:
	var scroll := _scroll_value + _drag_scroll_value
	if border_limit > 0:
		scroll = clampi(scroll, -_get_relevant_axis() * (_item_count - 1) - border_limit, border_limit)
	return scroll
func _get_children() -> Array[Control]:
	var ret : Array[Control]
	for child : Node in get_children():
		if child is Control:
			ret.append(child)
	return ret

func _loop_index(idx : int) -> int:
	if _item_count == 0: return 0
	return (idx + _item_count) % _item_count

func _create_animation(idx : int, snap : bool) -> void:
	_kill_animation()
	_scroll_tween = create_tween()
	
	if snap:
		_scroll_tween.tween_method(
			_animation_method,
			_scroll_value,
			-_get_relevant_axis() * idx,
			snap_duration)
		_scroll_tween.set_ease(snap_ease_type)
		_scroll_tween.set_trans(snap_transtion_type)
	else:
		_scroll_tween.tween_method(
			_animation_method,
			_scroll_value,
			-_get_relevant_axis() * idx,
			carousel_duration)
		_scroll_tween.set_ease(carousel_ease_type)
		_scroll_tween.set_trans(carousel_transtion_type)
	_scroll_tween.play()
func _animation_method(scroll : int) -> void:
	_scroll_value = scroll
	_adjust_children()
func _kill_animation() -> void:
	if _scroll_tween && _scroll_tween.is_running():
		_scroll_tween.kill()

func _get_child_rect(child : Control, index : int) -> Rect2:
	var child_pos : Vector2
	var child_size : Vector2
	
	if vertical: child_pos.y = item_size.y * index
	else: child_pos.x = item_size.x * index
	
	child_size = child.get_combined_minimum_size()
	match child.size_flags_horizontal:
		SIZE_FILL: child_size.x = item_size.x
		SIZE_SHRINK_BEGIN: pass
		SIZE_SHRINK_CENTER: child_pos.x += (item_size.x - child_size.x) * 0.5
		SIZE_SHRINK_END: child_pos.x += (item_size.x - child_size.x)
	match child.size_flags_vertical:
		SIZE_FILL: child_size.y = item_size.y
		SIZE_SHRINK_BEGIN: pass
		SIZE_SHRINK_CENTER: child_pos.y += (item_size.y - child_size.y) * 0.5
		SIZE_SHRINK_END: child_pos.y += (item_size.y - child_size.y)
	
	child.size = child_size
	child.position = child_pos
	
	return Rect2(child_pos, child_size)
func _settup_children() -> void:
	var children : Array[Control] = _get_children()
	_item_count = children.size()
	
	_child_rects.resize(_item_count)
	for i : int in range(0, _item_count):
		_child_rects[i] = _get_child_rect(children[i], i)
func _adjust_children() -> void:
	var scroll := _get_adjusted_scroll()
	var children : Array[Control] = _get_children()
	if vertical:
		for i : int in range(0, _item_count):
			children[i].position = _child_rects[i].position + Vector2(0, scroll)
	else:
		for i : int in range(0, _item_count):
			children[i].position = _child_rects[i].position + Vector2(scroll, 0)

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]

# Signals too
#func _on_snap_to_item() -> void: pass
#func _on_drag_start() -> void: pass
#func _on_drag_end() -> void: pass
#func _while_scroll(progress : int) -> void: pass
