# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableTransformationMount extends AnimatableMount
## An [AnimatableMount] that adjusts for it's children 2D transformations: Rotation, Position, and Scale.


## If [code]true[/code] this node will adjust it's size to fit its children's scales.
@export var adjust_scale : bool:
	set(val):
		if val != adjust_scale:
			adjust_scale = val
			update_minimum_size()
## If [code]true[/code] this node will adjust it's size to fit its children's rotations.[br]
## [b]NOTE[/b]: A large [member pivot_offset] can cause floating point precision issues.
@export var adjust_rotate : bool:
	set(val):
		if val != adjust_rotate:
			adjust_rotate = val
			update_minimum_size()
## If [code]true[/code] this node adjust its children's positions inside it's size.
@export var adjust_position : bool:
	set(val):
		if val != adjust_position:
			adjust_position = val
			update_minimum_size()

var _child_min_size : Vector2



## Returns the adjusted size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2:
	if adjust_scale:
		return _child_min_size / control.scale
	return _child_min_size


func _update_children_minimum_size() -> void:
	var _old_min_size := _min_size
	_min_size = Vector2.ZERO
	_child_min_size = Vector2.ZERO
	
	var children_info: Array[Array] = []
	
	for child : AnimatableControl in get_children():
		if child:
			var child_size : Vector2
			var child_offset : Vector2
			
			# Scale child size, if needed
			if adjust_scale:
				child_size = child.get_combined_minimum_size() * child.scale
			else:
				child_size = child.get_combined_minimum_size()
			_child_min_size = _child_min_size.max(child_size)
			
			# Rotates child size, if needed.
			if adjust_rotate:
				child_offset = child.pivot_offset
				if adjust_scale: child_offset *= child.scale
				
				# Gets the bounding box of the rect, when rotated around a pivot
				var bb_rect := _get_rotated_rect_bounding_box(
					Rect2(Vector2.ZERO, child_size),
					child_offset,
					child.rotation
				)
				
				child_size = bb_rect.size
				child_offset = bb_rect.position
			
			children_info.append([child, child_size, child_offset])
			_min_size = _min_size.max(child_size)
	
	# Leaves position adjusts after so size, after calculating min-size of children, can be used 
	if adjust_position:
		if _old_min_size != _min_size:
			# If in Container, and min_size changed, update after the container as resorted children
			if get_parent_control() is Container:
				get_parent_control().sort_children.connect(_adjust_children_positions.bind(children_info), CONNECT_ONE_SHOT)
			else:
				# Otherwise, if min_size changed still, update after minimum_size_changed changed
				minimum_size_changed.connect(_adjust_children_positions.bind(children_info), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
			update_minimum_size()
		else:
			# If min_size did not change, deffer children position changes
			call_deferred("_adjust_children_positions", children_info)
	elif _old_min_size != _min_size:
		update_minimum_size()
func _adjust_children_positions(children_info: Array[Array]) -> void:
	for child_info : Array in children_info:
		var child : AnimatableControl = child_info[0]
		var child_size : Vector2 = child_info[1]
		var child_offset : Vector2 = child_info[2]
		
		var piv_offset : Vector2
		# Rotates pivot, if needed
		if adjust_rotate:
			piv_offset = -child.pivot_offset.rotated(rotation)
		else:
			piv_offset = -child.pivot_offset
		# If adjusts the pivot by scale, if needed
		if adjust_scale:
			piv_offset *= (child.scale - Vector2.ONE)
		
		# Not clamp, because min should have priorty
		# max_size_adjusted_for_child_size = size - child_size - child_offset - piv_offset
		# min_size_adjusted_for_child_size = -piv_offset - child_offset
		var new_pos := child.position.min(size - child_size - child_offset - piv_offset).max(-piv_offset - child_offset)
		
		# Changes position, if needed
		if child.position != new_pos: child.position = new_pos

func _get_rotated_rect_bounding_box(rect : Rect2, pivot : Vector2, angle : float) -> Rect2:
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



func _on_mount(control : AnimatableControl) -> void:
	control.transformation_changed.connect(update_minimum_size, CONNECT_DEFERRED)
func _on_unmount(control : AnimatableControl) -> void:
	control.transformation_changed.disconnect(update_minimum_size)



func _init() -> void:
	size_flags_changed.connect(update_minimum_size, CONNECT_DEFERRED)
	super()

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
