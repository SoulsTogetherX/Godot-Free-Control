# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableTransformationMount extends AnimatableMount
## An [AnimatableMount] that adjusts for it's children 2D transformations: Rotation, Position, and Scale.

#region Enums
enum TRANSFORMATION_MODE {
	SCALE = 1 << 0,
	ROTATION = 1 << 1,
	POSITION = 1 << 2
}
#endregion


#region External Variables
@export_flags("Scale:1", "Rotate:2", "Position:4") var transformation : int:
	set(val):
		if val != transformation:
			transformation = val
			update_minimum_size()
#endregion


#region Private Variables
var _child_min_size : Vector2
#endregion


#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var _min_size := Vector2.ZERO
	_child_min_size = Vector2.ZERO
	
	var children_info: Array[Array] = []
	
	for child : Node in get_children():
		if child is AnimatableControl:
			var child_bb := _get_child_exact_bb(child)
			
			# Scale child size, if needed
			_child_min_size = _child_min_size.max(_get_scaled_child_size(child))
			
			children_info.append([child, child_bb])
			_min_size = _min_size.max(child_bb.size)
	
	# Leaves position adjusts after so size, after calculating min-size of children, can be used 
	if transformation & TRANSFORMATION_MODE.POSITION:
		for info : Array in children_info:
			_adjust_children_positions(info[0], info[1])
	
	return _min_size
#endregion


#region Custom Virtual Methods
func _on_transformation_changed() -> void:
	if transformation & TRANSFORMATION_MODE.POSITION:
		for child : Node in get_children():
			if child is AnimatableControl:
				_adjust_children_positions(child, _get_child_exact_bb(child))
#endregion


#region Private Methods
func _adjust_children_positions(
	child : AnimatableControl,
	child_bb : Rect2
) -> void:
	var piv_offset : Vector2
	
	# Rotates pivot, if needed
	if transformation & TRANSFORMATION_MODE.ROTATION:
		var piv := child.pivot_offset
		if transformation & TRANSFORMATION_MODE.SCALE:
			piv *= child.scale
		
		piv_offset = child.pivot_offset - piv.rotated(child.rotation)
		
	
	# If adjusts the pivot by scale, if needed
	elif transformation & TRANSFORMATION_MODE.SCALE:
		piv_offset -= child.pivot_offset * (child.scale - Vector2.ONE)
	
	# Not clamp because min should have priorty
	var new_pos := child.position.min(size - child_bb.size - child_bb.position - piv_offset).max(-piv_offset - child_bb.position)
	
	# Changes position, if needed
	if child.position != new_pos:
		child.position = new_pos

func _get_scaled_child_size(child : AnimatableControl) -> Vector2:
	if transformation & TRANSFORMATION_MODE.SCALE:
		return child.size * child.scale
	return child.size
func _get_rotated_bb(rect : Rect2, pivot : Vector2, angle : float) -> Rect2:
	# Base Values
	var pos := rect.position
	var sze := rect.size
	var trig := Vector2(cos(angle), sin(angle))
	
	# Simplified equation for centerPoint - bb_size*0.5
	var bb_pos := Vector2(
		(sze.x * (trig.x - abs(trig.x)) - sze.y * (trig.y + abs(trig.y))) * 0.5 + pivot.x * (1 - trig.x) + trig.y * pivot.y + pos.x,
		(sze.x * (trig.y - abs(trig.y)) + sze.y * (trig.x - abs(trig.x))) * 0.5 + pivot.y * (1 - trig.x) - trig.y * pivot.x + pos.y
	)
	trig = trig.abs()
	## Finds the fix of the bounding box of the rotated rectangle
	var bb_size := Vector2(
		sze.x * trig.x + sze.y * trig.y,
		sze.x * trig.y + sze.y * trig.x
	)
	
	return Rect2(bb_pos, bb_size)
func _get_child_exact_bb(child : AnimatableControl) -> Rect2:
	var ret : Rect2
	
	# Scale child size, if needed
	ret.size = _get_scaled_child_size(child)
	
	# Rotates child size, if needed.
	if transformation & TRANSFORMATION_MODE.ROTATION:
		var pivot := child.pivot_offset
		if transformation & TRANSFORMATION_MODE.SCALE:
			pivot *= child.scale
		
		# Gets the bounding box of the rect, when rotated around a pivot
		ret = _get_rotated_bb(
			Rect2(Vector2.ZERO, ret.size),
			ret.position,
			child.rotation
		)
	return ret
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
