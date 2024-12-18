@tool
class_name MaxSizeContainer extends Container

var _max_size := -Vector2.ONE
@export var max_size : Vector2 = -Vector2.ONE:
	get: return _max_size
	set(val):
		_max_size = val
		_handle_resize()

@export var use_top_left : bool = false:
	set(val):
		use_top_left = val
		_handle_resize()

func _ready() -> void:
	resized.connect(_handle_resize)
	_handle_resize()

func _handle_resize() -> void:
	if !is_node_ready(): return
	
	update_minimum_size()
	_before_resize_children()
	_resize_childrend()

func _before_resize_children() -> void: pass
func _resize_childrend() -> void:
	for x in get_children():
		if x is Control:
			_resize_child(x)
func _resize_child(child : Control):
	if (_max_size.x < 0.0 && _max_size.y < 0.0) || is_zero_approx(size.x) || is_zero_approx(size.y ):
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
		return
	
	var minsize := child.get_minimum_size()
	var result_size := Vector2.ZERO
	
	result_size = Vector2(
		maxf(size.x if _max_size.x < 0 else minf(size.x, _max_size.x), minsize.x),
		maxf(size.y if _max_size.y < 0 else minf(size.y, _max_size.y), minsize.y),
	)
	
	if use_top_left:
		fit_child_in_rect(child, Rect2(Vector2.ZERO, result_size))
	else:
		fit_child_in_rect(child, Rect2((size - result_size) * 0.5, result_size))

func _get_minimum_size() -> Vector2:
	var max_min_child_size : Vector2 = Vector2.ZERO;
	for c in get_children(true):
		if c is Control:
			max_min_child_size = max_min_child_size.max(c.get_minimum_size())
	return max_min_child_size
