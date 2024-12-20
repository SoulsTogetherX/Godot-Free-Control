@tool
class_name AnimatableTransformationMount extends AnimatableMount
## An [AnimatableMount] that adjusts for te transformation of it's children [AnimatableControl] nodes.
## [br][br]
## Currently only works for scale transformations.

## If [code]true[/code] this node will adjust it's size according to it's children scale
@export var adjust_scale : bool:
	set(val):
		if val != adjust_scale:
			adjust_scale = val
			_update_children_minimum_size()

var _updating_children : bool

func _update_children_minimum_size() -> void:
	if _updating_children: return
	_updating_children = true
	
	var _old_min_size := _min_size
	var offset := Vector2.ZERO
	_min_size = Vector2.ZERO
	
	for child : AnimatableControl in get_children():
		if child:
			var child_min : Vector2
			if adjust_scale:
				child_min = child.get_combined_minimum_size() * child.scale
			else:
				child_min = child.get_combined_minimum_size()
			_min_size = _min_size.max(child_min)
	
	if _old_min_size != _min_size: update_minimum_size()
	_updating_children = false
func _offset_all_children_positions(offset : Vector2) -> void:
	if offset == Vector2.ZERO: return
	for child : AnimatableControl in get_children():
		if child: child.position += offset
	position -= offset

func _on_mount(control : AnimatableControl) -> void:
	control.transformation_changed.connect(_update_children_minimum_size, CONNECT_DEFERRED)
func _on_unmount(control : AnimatableControl) -> void:
	control.transformation_changed.disconnect(_update_children_minimum_size)

## Returns the adjusted size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2:
	if adjust_scale:
		return _min_size / control.scale
	return _min_size
