# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxSizeContainer extends Container
## A container that limits it's size to a maximum value.

var _max_size := -Vector2.ONE
## The maximum size this container can possess.
## [br][br]
## If one of the axis is [code]-1[/code], then it is boundless.
@export var max_size : Vector2 = -Vector2.ONE:
	get: return _max_size
	set(val):
		_max_size = val
		_handle_resize()
## If [code]true[/code], positions children relative to the container's top left corner.
@export var use_top_left : bool = false:
	set(val):
		use_top_left = val
		_handle_resize()

func _ready() -> void:
	if !resized.is_connected(_handle_resize):
		resized.connect(_handle_resize, CONNECT_PERSIST)
	if !sort_children.is_connected(_handle_resize):
		sort_children.connect(_handle_resize, CONNECT_PERSIST)
	_handle_resize()
func _get_minimum_size() -> Vector2:
	var max_min_child_size : Vector2 = Vector2.ZERO;
	for c : Node in get_children(true):
		if c is Control:
			max_min_child_size = max_min_child_size.max(c.get_minimum_size())
	return max_min_child_size

## A helper function that should be called whenever this node's size needs to be changed, or when it's children are changed.
func _handle_resize() -> void:
	if !is_node_ready(): return
	
	# Handles everything needed to change max_size and rebound all children
	update_minimum_size()
	_before_resize_children()
	_update_childrend()

## A virtual helper function that should be used when creating your own MaxSizeContainers.[br]
## Is called when [method _handle_resize] is called. The minimum_size of this node will be calculated first, before this is called.
func _before_resize_children() -> void: pass
func _update_childrend() -> void:
	for x : Node in get_children():
		if x is Control:
			_update_child(x)
func _update_child(child : Control):
	var child_min_size := child.get_minimum_size()
	var result_size := Vector2.ZERO
	result_size = Vector2(
		maxf(size.x if _max_size.x < 0 else minf(size.x, _max_size.x), child_min_size.x),
		maxf(size.y if _max_size.y < 0 else minf(size.y, _max_size.y), child_min_size.y),
	)
	
	var set_pos : Vector2
	match size_flags_horizontal:
		SIZE_FILL:
			set_pos.x = 0
			result_size.x = max(result_size.x, size.x)
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_CENTER:
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_END:
			set_pos.x = size.x - result_size.x
	match size_flags_vertical:
		SIZE_FILL:
			set_pos.y = 0
			result_size.y = max(result_size.y, size.y)
		SIZE_SHRINK_BEGIN:
			set_pos.y = 0
		SIZE_SHRINK_CENTER:
			set_pos.y = (size.y - result_size.y) * 0.5
		SIZE_SHRINK_END:
			set_pos.y = size.y - result_size.y
	
	fit_child_in_rect(child, Rect2(set_pos, result_size))

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]

# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
