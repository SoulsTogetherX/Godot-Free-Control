# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name PaddingContainer extends Container
## A [Container] that provides percentage and numerical padding to it's children.

#region External Variables
## If [code]true[/code], this [Container]'s minimum size will update according to it's
## children and numerical pixel padding.
@export var minimum_size : bool = true:
	set(val):
		if minimum_size != val:
			minimum_size = val
			
			update_minimum_size()
			queue_sort()

## The percentage left padding.
var child_anchor_left : float = 0:
	set(val):
		if child_anchor_left != val:
			child_anchor_left = val
			
			child_anchor_right = maxf(val, child_anchor_right)
			update_minimum_size()
			queue_sort()
## The percentage top padding.
var child_anchor_top : float = 0:
	set(val):
		if child_anchor_top != val:
			child_anchor_top = val
			
			child_anchor_bottom = maxf(val, child_anchor_bottom)
			update_minimum_size()
			queue_sort()
## The percentage right padding.
var child_anchor_right : float = 1:
	set(val):
		if child_anchor_right != val:
			child_anchor_right = val
			
			child_anchor_left = minf(val, child_anchor_left)
			update_minimum_size()
			queue_sort()
## The percentage bottom padding.
var child_anchor_bottom : float = 1:
	set(val):
		if child_anchor_bottom != val:
			child_anchor_bottom = val
			
			child_anchor_top = minf(val, child_anchor_top)
			update_minimum_size()
			queue_sort()

## The numerical pixel left padding.
var child_offset_left : int = 0:
	set(val):
		val = maxi(val, 0)
		if child_offset_left != val:
			child_offset_left = val
			
			update_minimum_size()
			queue_sort()
## The numerical pixel top padding.
var child_offset_top : int = 0:
	set(val):
		val = maxi(val, 0)
		if child_offset_top != val:
			child_offset_top = val
			
			update_minimum_size()
			queue_sort()
## The numerical pixel right padding.
var child_offset_right : int = 0:
	set(val):
		val = maxi(val, 0)
		if child_offset_right != val:
			child_offset_right = val
			
			update_minimum_size()
			queue_sort()
## The numerical pixel bottom padding.
var child_offset_bottom : int = 0:
	set(val):
		val = maxi(val, 0)
		if child_offset_bottom != val:
			child_offset_bottom = val
			
			update_minimum_size()
			queue_sort()
#endregion


#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if !minimum_size || clip_contents:
		return Vector2.ZERO
	
	var min : Vector2
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
			min = min.max(child.get_combined_minimum_size())
	
	min += get_parent_area_size() * Vector2(
		child_anchor_left + (1 - child_anchor_right),
		child_anchor_top + (1 - child_anchor_bottom)
	)
	min += Vector2(
		child_offset_left + child_offset_right,
		child_offset_top + child_offset_bottom
	)
	
	return min

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	
	properties.append({
		"name" = "Anchors",
		"type" = TYPE_NIL,
		"usage" = PROPERTY_USAGE_GROUP,
		"hint_string" = "child_anchor_"
	})
	properties.append({
		"name": "child_anchor_left",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.001,or_greater, or_less"
	})
	properties.append({
		"name": "child_anchor_top",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater, or_less"
	})
	properties.append({
		"name": "child_anchor_right",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater, or_less"
	})
	properties.append({
		"name": "child_anchor_bottom",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater, or_less"
	})
	
	properties.append({
		"name" = "Offsets",
		"type" = TYPE_NIL,
		"usage" = PROPERTY_USAGE_GROUP,
		"hint_string" = "child_offset_"
	})
	properties.append({
		"name": "child_offset_left",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_top",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_right",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_bottom",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, hide_slider, suffix:px"
	})
	
	return properties
func _property_can_revert(property: StringName) -> bool:
	if property in [
		"child_anchor_left",
		"child_anchor_top",
	]:
		return self[property] != 0.0
	elif property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return self[property] != 1.0
	elif property in [
		"child_offset_left",
		"child_offset_top",
		"child_offset_right",
		"child_offset_bottom"
	]:
		return self[property] != 0
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property in [
		"child_anchor_left",
		"child_anchor_top",
	]:
		return 0.0
	elif property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return 1.0
	elif property in [
		"child_offset_left",
		"child_offset_top",
		"child_offset_right",
		"child_offset_bottom"
	]:
		return 0
	return null

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_SHRINK_BEGIN, SIZE_FILL, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_SHRINK_BEGIN, SIZE_FILL, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
#endregion


#region Private Methods
func _sort_children() -> void:
	var rect := get_padding_rect()
	
	for child : Node in get_children():
		if child is Control:
			_sort_child(child, rect)
func _sort_child(child : Control, rect : Rect2) -> void:
	var min_size := child.get_combined_minimum_size()
	
	match child.size_flags_horizontal:
		SIZE_SHRINK_BEGIN:
			rect.size.x = min_size.x
		SIZE_SHRINK_CENTER:
			rect.position.x += (rect.size.x - min_size.x) * 0.5
			rect.size.x = min_size.x
		SIZE_SHRINK_END:
			rect.position.x += (rect.size.x - min_size.x)
			rect.size.x = min_size.x
	
	match child.size_flags_vertical:
		SIZE_SHRINK_BEGIN:
			rect.size.y = min_size.y
		SIZE_SHRINK_CENTER:
			rect.position.y += (rect.size.y - min_size.y) * 0.5
			rect.size.y = min_size.y
		SIZE_SHRINK_END:
			rect.position.y += (rect.size.y - min_size.y)
			rect.size.y = min_size.y
	
	fit_child_in_rect(child, rect)
#endregion


#region Private Methods
## Returns the rect of the total area the children will fill after padding calculations.
func get_padding_rect() -> Rect2:
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
