# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxSizeContainer extends Container
## A container that limits it's size to a maximum value.

#region External Variables
var _max_size := -Vector2.ONE
## The maximum size this container can possess.
## [br][br]
## If one of the axis is [code]-1[/code], then it is boundless.
@export var max_size : Vector2 = -Vector2.ONE:
	get: return _max_size
	set(val):
		_max_size = val
		queue_sort()
#endregion


#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2 = Vector2.ZERO
	for child : Control in _get_control_children():
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _set(property: StringName, value: Variant) -> bool:
	if property == "size":
		return true
	return false

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			call_deferred("_sort_children")
#endregion


#region Private Methods
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control && child.visible))
	return ret

func _sort_children() -> void:
	update_minimum_size()
	_update_children()

func _update_children() -> void:
	for child : Control in _get_control_children():
		_update_child(child)
func _update_child(child : Control):
	var child_min_size := child.get_minimum_size()
	var set_pos : Vector2
	var result_size := Vector2(
		size.x if _max_size.x < 0 else minf(size.x, _max_size.x),
		size.y if _max_size.y < 0 else minf(size.y, _max_size.y)
	)
	
	if child.size_flags_horizontal & SIZE_EXPAND_FILL:
		result_size.x = maxf(result_size.x, child_min_size.x)
	else:
		result_size.x = minf(result_size.x, child_min_size.x)
	if child.size_flags_vertical & SIZE_EXPAND_FILL:
		result_size.y = maxf(result_size.y, child_min_size.y)
	else:
		result_size.y = minf(result_size.y, child_min_size.y)
	
	
	match child.size_flags_horizontal & ~SIZE_EXPAND:
		SIZE_SHRINK_CENTER, SIZE_FILL:
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_END:
			set_pos.x = size.x - result_size.x
	match child.size_flags_vertical & ~SIZE_EXPAND:
		SIZE_SHRINK_CENTER, SIZE_FILL:
			set_pos.y = (size.y - result_size.y) * 0.5
		SIZE_SHRINK_BEGIN:
			set_pos.y = 0
		SIZE_SHRINK_END:
			set_pos.y = size.y - result_size.y
	
	child.position = set_pos
	child.size = result_size
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
