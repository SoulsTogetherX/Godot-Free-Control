# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxSizeContainer extends Container
## A container that limits it's size to a maximum value.

var _min_size := -Vector2.ONE
var _max_size := -Vector2.ONE
## The maximum size this container can possess.
## [br][br]
## If one of the axis is [code]-1[/code], then it is boundless.
@export var max_size : Vector2 = -Vector2.ONE:
	get: return _max_size
	set(val):
		_max_size = val
		queue_sort()

var _ignore_resize : bool

func _ready() -> void:
	if !sort_children.is_connected(_handle_sort):
		sort_children.connect(_handle_sort)
	_handle_sort()
func _set(property: StringName, value: Variant) -> bool:
	if property == "size":
		return true
	return false
func _find_minimum_size() -> Vector2:
	var min_size : Vector2 = Vector2.ZERO
	for child : Control in _get_control_children():
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _get_minimum_size() -> Vector2:
	_min_size = _find_minimum_size()
	return _min_size
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control && child.visible))
	return ret



## A helper function that should be called whenever this node's size needs to be changed, or when it's children are changed.
func _handle_sort() -> void:
	if _ignore_resize: return
	_ignore_resize = true
	
	# Handles everything needed to change max_size and rebound all children
	update_minimum_size()
	_before_resize_children()
	
	_ignore_resize = false
	_update_childrend()

## A virtual helper function that should be used when creating your own MaxSizeContainers.[br]
## Is called when [method _handle_resize] is called. The minimum_size of this node will be calculated first, before this is called.
func _before_resize_children() -> void: pass
func _update_childrend() -> void:
	for child : Control in _get_control_children():
		_update_child(child)
func _update_child(child : Control):
	var child_min_size := child.get_minimum_size()
	var result_size := Vector2.ZERO
	result_size = Vector2(
		maxf(size.x if _max_size.x < 0 else minf(size.x, _max_size.x), child_min_size.x),
		maxf(size.y if _max_size.y < 0 else minf(size.y, _max_size.y), child_min_size.y),
	)
	
	var set_pos : Vector2
	match child.size_flags_horizontal & ~SIZE_EXPAND:
		SIZE_FILL:
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_CENTER:
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_END:
			set_pos.x = size.x - result_size.x
	match child.size_flags_vertical & ~SIZE_EXPAND:
		SIZE_FILL:
			set_pos.y = (size.y - result_size.y) * 0.5
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

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
