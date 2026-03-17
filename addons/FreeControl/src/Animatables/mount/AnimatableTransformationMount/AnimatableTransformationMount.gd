# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
@icon("uid://cotvxfxb3vswy")
class_name AnimatableTransformationMount extends AnimatableMount
## An [AnimatableMount] that adjusts for it's children
## [AnimatableControl]'s transformations: Rotation, Position, and Scale.

#region Enums
enum TRANSFORMATION_MODE {
	SCALE = 1 << 0,
	ROTATION = 1 << 1,
	POSITION = 1 << 2
}
#endregion


#region External Variables
## A flag mask of the transformations this mount will account for.
## [br][br]
## Also see [enum TRANSFORMATION_MODE].
@export_flags("Scale:1", "Rotate:2", "Position:4") var transformation_mask : int:
	set(val):
		if val != transformation_mask:
			transformation_mask = val
			_on_transform_changed()

## If [code]true[/code], this mount will use [AnimatableControl]
## children's own [Control.size] in calculations, instead of it's
## minimum size.
@export var maintain_size : bool 
#endregion



#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var _min_size := Vector2.ZERO
	for child : Node in get_children():
		if child is AnimatableControl && child.is_visible_in_tree():
			_min_size = _min_size.max(_get_adjusted_child_min_size(child))
	
	return _min_size
#endregion


#region Private Methods (Signal Connection)
func _connect_animatable(animatable : AnimatableControl) -> void:
	super(animatable)
	
	animatable.transformation_changed.connect(_on_transform_changed)
func _disconnect_animatable(animatable : AnimatableControl) -> void:
	super(animatable)
	
	animatable.transformation_changed.disconnect(_on_transform_changed)
#endregion


#region Private Methods (Sort)
func _sort_child(child : AnimatableControl) -> void:
	match child.size_mode:
		AnimatableControl.SIZE_MODE.MIN:
			child.size = get_relative_size(child).max(child.size)
		AnimatableControl.SIZE_MODE.MAX:
			child.size = get_relative_size(child).min(child.size)
		AnimatableControl.SIZE_MODE.EXACT:
			child.size = get_relative_size(child)

	if transformation_mask & TRANSFORMATION_MODE.POSITION != 0:
		_reposition_child(child)
#endregion


#region Private Methods (Bounding Box)
func _get_bounding_box(xform: Transform2D, t_size: Vector2) -> Rect2:
	var min_v := Vector2(INF, INF)
	var max_v := Vector2(-INF, -INF)

	var corners: PackedVector2Array = [
		Vector2.ZERO,
		Vector2(t_size.x, 0),
		Vector2(0, t_size.y),
		t_size
	]

	for p : Vector2 in corners:
		p = xform * p
		min_v = min_v.min(p)
		max_v = max_v.max(p)
	return Rect2(min_v, max_v - min_v)

func _get_child_bb(child: AnimatableControl) -> Rect2:
	var xform := _get_child_xform(child)
	return _get_bounding_box(xform, child.size)
#endregion


#region Private Methods (Transformations)
func _on_transform_changed() -> void:
	update_minimum_size()
	queue_sort()

func _get_child_xform(child : AnimatableControl) -> Transform2D:
	var scalar : Vector2 = child.scale if transformation_mask & TRANSFORMATION_MODE.SCALE != 0 else Vector2.ONE
	var rot : float = child.rotation if transformation_mask & TRANSFORMATION_MODE.ROTATION != 0 else 0.0
	
	var pivot := child.get_combined_pivot_offset()
	var xform := Transform2D(rot, scalar, 0.0, Vector2.ZERO)
	xform.origin = child.position + pivot - xform.basis_xform(pivot)
	
	return xform

func _get_adjusted_child_min_size(child : AnimatableControl) -> Vector2:
	if child.size_mode == AnimatableControl.SIZE_MODE.MAX:
		var bb := _get_child_bb(child)
		return bb.size
	return child.get_minimum_size()

func _reposition_child(child: Control) -> void:
	var bb := _get_child_bb(child)
	child.position -= bb.position
#endregion


#region Public Methods
## Returns the relative size of the child after being reduced by
## it's scale and rotation.
## [br][br]
## Also see [member transformation_mask] and [Transform2D].
func get_relative_size(child : Control) -> Vector2:
	var xform := _get_child_xform(child)

	var ax := absf(xform.x.x)
	var ay := absf(xform.x.y)
	var bx := absf(xform.y.x)
	var by := absf(xform.y.y)
	var det := ax * by - bx * ay
	
	# Prevents ambiguity at small sizes
	if is_zero_approx(det):
		var x_sum := ax + bx
		var y_sum := ay + by
		
		if is_zero_approx(x_sum):
			return Vector2.ZERO
		if is_zero_approx(y_sum):
			return Vector2.ZERO
		
		var sx := size.x / x_sum
		var sy := size.y / y_sum
		var uniform := minf(sx, sy)
		return Vector2(uniform, uniform)

	return Vector2(
		(by * size.x - bx * size.y) / det,
		(-ay * size.x + ax * size.y) / det
	)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
