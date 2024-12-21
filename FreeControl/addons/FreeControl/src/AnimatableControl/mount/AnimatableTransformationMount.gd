@tool
class_name AnimatableTransformationMount extends AnimatableMount
## An [AnimatableMount] that adjusts for it's children 2D transformations: Rotation, Position, and Scale.

## If [code]true[/code] this node will adjust it's size to fit its children's scales.
@export var adjust_scale : bool:
	set(val):
		if val != adjust_scale:
			adjust_scale = val
			queue_minimum_size_update()
## If [code]true[/code] this node will adjust it's size to fit its children's rotations.
@export var adjust_rotate : bool:
	set(val):
		if val != adjust_rotate:
			adjust_rotate = val
			queue_minimum_size_update()
## If [code]true[/code] this node adjust to fit its children's positions inside it's size.[br]
## If this node is a child to a [Container], it will bound all children to be inside of it's existing size.[bt]
## Otherwise, this node will expand to the bottom-right until all children are fully inside of it's size.
@export var adjust_position : bool:
	set(val):
		if val != adjust_position:
			adjust_position = val
			queue_minimum_size_update()

var _child_min_size : Vector2

func _update_children_minimum_size() -> void:
	var parent : Container = (get_parent_control() as Container)
	var _old_min_size := _min_size
	var offset := Vector2.ZERO
	_min_size = Vector2.ZERO
	_child_min_size = Vector2.ZERO
	
	for child : AnimatableControl in get_children():
		if child:
			var child_size : Vector2
			var child_offset : Vector2
			
			if adjust_scale: child_size = child.get_combined_minimum_size() * child.scale
			else: child_size = child.get_combined_minimum_size()
			_child_min_size = _child_min_size.max(child_size)
			
			if adjust_rotate:
				var child_pivot : Vector2 = child.pivot_offset
				if adjust_scale: child_pivot *child.scale
				
				var bb_rect := _get_rotated_rect_bounding_box(
					Rect2(Vector2.ZERO, child_size),
					child_pivot,
					child.rotation
				)
				child_size = bb_rect.size
				child_offset = bb_rect.position
			
			if adjust_position:
				var pivot_inc := child.pivot_offset
				if adjust_scale: pivot_inc *= (child.scale - Vector2.ONE)
				var child_correct_pos := child.position.max(pivot_inc - child_offset)
				
				var new_pos : Vector2
				if parent:
					var parent_size := size - child_size - child_offset + pivot_inc
					new_pos = child_correct_pos.min(parent_size)
				else:
					child_size += child_correct_pos + child_offset - pivot_inc
					new_pos = child_correct_pos.max(pivot_inc - child_offset)
				
				if child.position != new_pos: child.position = new_pos
			_min_size = _min_size.max(child_size)
	if _old_min_size != _min_size:
		update_minimum_size()
func _get_rotated_rect_bounding_box(rect : Rect2, pivot : Vector2, angle : float) -> Rect2:
	var pos := rect.position
	var sze := rect.size
	
	var trig := Vector2(cos(angle), sin(angle))
	var center := Vector2(
		trig.x * (sze.x - 2 * pivot.x) - trig.y * (sze.y - 2 * pivot.y) + 2 * (pivot.x + pos.x),
		trig.y * (sze.x - 2 * pivot.x) + trig.x * (sze.y - 2 * pivot.y) + 2 * (pivot.y + pos.y)
	) * 0.5
	
	trig = trig.abs()
	var bb_size := Vector2(
		sze.x * trig.x + sze.y * trig.y,
		sze.x * trig.y + sze.y * trig.x
	)
	var bb_pos := center - (bb_size * 0.5)
	
	return Rect2(bb_pos, bb_size)

func _on_mount(control : AnimatableControl) -> void:
	control.transformation_changed.connect(queue_minimum_size_update, CONNECT_DEFERRED)
func _on_unmount(control : AnimatableControl) -> void:
	control.transformation_changed.disconnect(queue_minimum_size_update)

## Returns the adjusted size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2:
	if adjust_scale:
		return _child_min_size / control.scale
	return _child_min_size
