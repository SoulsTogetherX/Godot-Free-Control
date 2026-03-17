# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
@icon("uid://cheuwr5stowba")
class_name ExtrudeContainer extends RegionContainer
## A [Container] that provides an oppsite to [MarginContainer], best used
## for when you may want overlapping UI elements.


#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if !minimum_size || clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
			min_size = min_size.max(child.get_combined_minimum_size())
	
	min_size -= get_parent_area_size() * Vector2(
		child_anchor_left + child_anchor_right,
		child_anchor_top + child_anchor_bottom
	)
	min_size -= Vector2(
		child_offset_left + child_offset_right,
		child_offset_top + child_offset_bottom
	)
	
	return min_size.maxf(0.0)
#endregion


#region Private Methods
## Returns the rect of the total area the children will fill after extrude calculations.
func get_children_rect() -> Rect2:
	var ret_pos : Vector2
	var ret_size : Vector2
	
	ret_pos = Vector2(
		-(size.x * child_anchor_left) - child_offset_left,
		-(size.y * child_anchor_top) - child_offset_top
	)
	ret_size = Vector2(
		size.x * (child_anchor_left + child_anchor_right + 1.0) + (child_offset_right + child_offset_left),
		size.y * (child_anchor_bottom + child_anchor_top + 1.0) + (child_offset_bottom + child_offset_top)
	)
	
	return Rect2(ret_pos, ret_size)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
