# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
@icon("uid://mgfp36i5f8fb")
class_name PaddingContainer extends RegionContainer
## A [Container] that provides percentage and numerical padding to it's children.


#region Private Virtual Methods
func _init() -> void:
	child_anchor_right = 1.0
	child_anchor_bottom = 1.0

func _get_minimum_size() -> Vector2:
	if !minimum_size || clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
			min_size = min_size.max(child.get_combined_minimum_size())
	
	min_size += get_parent_area_size() * Vector2(
		child_anchor_left + (1 - child_anchor_right),
		child_anchor_top + (1 - child_anchor_bottom)
	)
	min_size += Vector2(
		child_offset_left + child_offset_right,
		child_offset_top + child_offset_bottom
	)
	
	return min_size

func _property_can_revert(property: StringName) -> bool:
	if property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return self[property] != 1.0
	return super(property)
func _property_get_revert(property: StringName) -> Variant:
	if property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return 1.0
	return super(property)
#endregion


#region Public Methods (Setters)
## Overwrites the [member child_anchor_left] setter.
func set_child_anchor_left(val : float) -> void:
	if child_anchor_left != val:
		child_anchor_left = val
		
		child_anchor_right = maxf(val, child_anchor_right)
		update_minimum_size()
		queue_sort()
## Overwrites the [member child_anchor_top] setter.
func set_child_anchor_top(val : float) -> void:
	if child_anchor_top != val:
		child_anchor_top = val
		
		child_anchor_bottom = maxf(val, child_anchor_bottom)
		update_minimum_size()
		queue_sort()
## Overwrites the [member child_anchor_right] setter.
func set_child_anchor_right(val : float) -> void:
	if child_anchor_right != val:
		child_anchor_right = val
		
		child_anchor_left = minf(val, child_anchor_left)
		update_minimum_size()
		queue_sort()
## Overwrites the [member child_anchor_bottom] setter.
func set_child_anchor_bottom(val : float) -> void:
	if child_anchor_bottom != val:
		child_anchor_bottom = val
		
		child_anchor_top = minf(val, child_anchor_top)
		update_minimum_size()
		queue_sort()
#endregion


#region Private Methods
## Returns the rect of the total area the children will fill after padding calculations.
func get_children_rect() -> Rect2:
	var ret_pos : Vector2
	var ret_size : Vector2
	
	ret_pos = Vector2(
		(size.x * child_anchor_left) + child_offset_left,
		(size.y * child_anchor_top) + child_offset_top
	)
	ret_size = Vector2(
		size.x * (child_anchor_right - child_anchor_left) - (child_offset_right + child_offset_left),
		size.y * (child_anchor_bottom - child_anchor_top) - (child_offset_bottom + child_offset_top)
	)
	
	return Rect2(ret_pos, ret_size)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
