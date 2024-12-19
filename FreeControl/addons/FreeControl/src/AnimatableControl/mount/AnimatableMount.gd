@tool
class_name AnimatableMount extends Control
## Used as a mount for size consistency between children [AnimatableControl] nodes.

var _min_size : Vector2

func _get_configuration_warnings() -> PackedStringArray:
	for child : AnimatableControl in get_children():
		if child: return []
	return ["This node has no 'AnimatableControl' nodes as children"]

## Increases the size of this mount to the given size, without decreasing.
##
## This is for interal usage between the [AnimatableControl] and this [AnimatableMount].
func grow_min_size(min : Vector2) -> void:
	var _min_old := _min_size
	_min_size = _min_size.max(min)
	if _min_old != _min_size:
		update_minimum_size()
## Resizes this mount's size to minimum size required to hold all [AnimatableControl] children.
##
## This is for interal usage between the [AnimatableControl] and this [AnimatableMount].
func update_children_min() -> void:
	var _min_old := _min_size
	_min_size = Vector2.ZERO
	for child : AnimatableControl in get_children():
		if child: _min_size = _min_size.max(child.get_combined_minimum_size())
	if _min_old != _min_size:
		update_minimum_size()
func _get_minimum_size() -> Vector2:
	return _min_size
