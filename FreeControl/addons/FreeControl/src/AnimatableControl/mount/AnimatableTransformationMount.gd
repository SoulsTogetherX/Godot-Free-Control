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
## If [code]true[/code] this node adjust to fit its children's positions inside it's size.
@export var adjust_position : bool:
	set(val):
		if val != adjust_position:
			adjust_position = val
			queue_minimum_size_update()

var _child_min_size : Vector2

func _update_children_minimum_size() -> void:
	var _old_min_size := _min_size
	_min_size = Vector2.ZERO
	_child_min_size = Vector2.ZERO
	
	var children_info: Array[Array] = []
	
	for child : AnimatableControl in get_children():
		if child:
			var child_size : Vector2
			var child_offset : Vector2
			
			if adjust_scale:
				child_size = child.get_combined_minimum_size() * child.scale
			else:
				child_size = child.get_combined_minimum_size()
			_child_min_size = _child_min_size.max(child_size)
			
			if adjust_rotate:
				var child_pivot : Vector2 = child.pivot_offset
				if adjust_scale: child_pivot * child.scale
				
				var bb_rect := _get_rotated_rect_bounding_box(
					Rect2(Vector2.ZERO, child.get_combined_minimum_size()),
					child.pivot_offset,
					child.rotation
				)
				if adjust_scale:
					bb_rect.size *= child.scale
					bb_rect.position *= child.scale
				
				child_size = bb_rect.size
				child_offset = bb_rect.position
			
			children_info.append([child, child_size, child_offset])
			_min_size = _min_size.max(child_size)
	
	if _old_min_size != _min_size:
		update_minimum_size()
	if adjust_position:
		if get_parent_control() is Container:
			get_parent_control().sort_children.connect(_adjust_children_positions.bind(children_info), CONNECT_ONE_SHOT)
		else:
			call_deferred("_adjust_children_positions", children_info)
func _adjust_children_positions(children_info: Array[Array]) -> void:
	for child_info : Array in children_info:
		var child : AnimatableControl = child_info[0]
		var child_size : Vector2 = child_info[1]
		var child_offset : Vector2 = child_info[2]
		
		var piv_offset : Vector2
		if adjust_rotate:
			piv_offset = -child.pivot_offset.rotated(rotation)
		else:
			piv_offset = -child.pivot_offset
		if adjust_scale:
			piv_offset *= (child.scale - Vector2.ONE)
		
		var parent_size := size - child_size - child_offset - piv_offset
		var new_pos := child.position.min(parent_size).max(-piv_offset - child_offset)
		
		if child.position != new_pos: child.position = new_pos
	

func _get_rotated_rect_bounding_box(rect : Rect2, pivot : Vector2, angle : float) -> Rect2:
	var pos := rect.position
	var sze := rect.size
	
	var trig := Vector2(cos(angle), sin(angle))
	var full := Vector2(
		trig.x * (sze.x - 2 * pivot.x) - trig.y * (sze.y - 2 * pivot.y) + 2 * (pivot.x + pos.x),
		trig.y * (sze.x - 2 * pivot.x) + trig.x * (sze.y - 2 * pivot.y) + 2 * (pivot.y + pos.y)
	)
	
	trig = trig.abs()
	var bb_size := Vector2(
		sze.x * trig.x + sze.y * trig.y,
		sze.x * trig.y + sze.y * trig.x
	)
	var bb_pos := (full - bb_size) * 0.5
	
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
