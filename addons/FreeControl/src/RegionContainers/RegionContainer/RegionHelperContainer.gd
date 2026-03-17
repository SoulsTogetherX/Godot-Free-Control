# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
@abstract
class_name RegionContainer extends Container
## An abstract [Container] class meant for the manipulation of children
## anchors. 

#region External Variables
## If [code]true[/code], this [Container]'s minimum size will update according to it's
## anchors.
@export var minimum_size : bool = true:
	set(val):
		if minimum_size != val:
			minimum_size = val
			
			update_minimum_size()
			queue_sort()

## The percentage left anchor.
var child_anchor_left : float:
	set = set_child_anchor_left
## The percentage top anchor.
var child_anchor_top : float:
	set = set_child_anchor_top
## The percentage right anchor.
var child_anchor_right : float:
	set = set_child_anchor_right
## The percentage bottom anchor.
var child_anchor_bottom : float:
	set = set_child_anchor_bottom

## The numerical pixel left anchor.
var child_offset_left : int:
	set = set_child_offset_left
## The numerical pixel top anchor.
var child_offset_top : int:
	set = set_child_offset_top
## The numerical pixel right anchor.
var child_offset_right : int:
	set = set_child_offset_right
## The numerical pixel bottom anchor.
var child_offset_bottom : int:
	set = set_child_offset_bottom
#endregion



#region Private Virtual Methods
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
		"hint_string": "0, 1, 0.001, or_greater, or_less"
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
		"hint_string": "0, 1, 1, or_greater, or_less, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_top",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, or_less, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_right",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, or_less, hide_slider, suffix:px"
	})
	properties.append({
		"name": "child_offset_bottom",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, or_less, hide_slider, suffix:px"
	})
	
	return properties
func _property_can_revert(property: StringName) -> bool:
	if property in [
		"child_offset_left",
		"child_offset_top",
		"child_offset_right",
		"child_offset_bottom"
	]:
		return self[property] != 0
	elif property in [
		"child_anchor_left",
		"child_anchor_top",
	]:
		return self[property] != 0.0
	elif property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return self[property] != 0.0
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property in [
		"child_offset_left",
		"child_offset_top",
		"child_offset_right",
		"child_offset_bottom"
	]:
		return 0
	elif property in [
		"child_anchor_left",
		"child_anchor_top",
	]:
		return 0.0
	elif property in [
		"child_anchor_right",
		"child_anchor_bottom",
	]:
		return 0.0
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


#region Private Methods (Sort)
func _sort_children() -> void:
	var rect := get_children_rect()
	
	for child : Node in get_children():
		if child is Control && child.is_visible_in_tree():
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


#region Public Methods (Setters)
## Sets the value of [member child_anchor_left].
func set_child_anchor_left(val : float) -> void:
	if child_anchor_left != val:
		child_anchor_left = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_anchor_top].
func set_child_anchor_top(val : float) -> void:
	if child_anchor_top != val:
		child_anchor_top = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_anchor_right].
func set_child_anchor_right(val : float) -> void:
	if child_anchor_right != val:
		child_anchor_right = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_anchor_bottom].
func set_child_anchor_bottom(val : float) -> void:
	if child_anchor_bottom != val:
		child_anchor_bottom = val
		
		update_minimum_size()
		queue_sort()


## Sets the value of [member child_offset_left].
func set_child_offset_left(val : int) -> void:
	val = maxi(val, 0)
	if child_offset_left != val:
		child_offset_left = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_offset_top].
func set_child_offset_top(val : int) -> void:
	val = maxi(val, 0)
	if child_offset_top != val:
		child_offset_top = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_offset_right].
func set_child_offset_right(val : int) -> void:
	val = maxi(val, 0)
	if child_offset_right != val:
		child_offset_right = val
		
		update_minimum_size()
		queue_sort()
## Sets the value of [member child_offset_bottom].
func set_child_offset_bottom(val : int) -> void:
	val = maxi(val, 0)
	if child_offset_bottom != val:
		child_offset_bottom = val
		
		update_minimum_size()
		queue_sort()
#endregion


#region Public Methods
## Returns the rect of the total area the children will fill after calculations.
@abstract
func get_children_rect() -> Rect2
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
