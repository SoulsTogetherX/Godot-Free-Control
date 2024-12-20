@tool
class_name CircularContainer extends Container
## A container that positions children in a ellipse within the bounds of this node.

## The horizontal offset of the ellipse's center.
## [br][br]
## [code]0[/code] is fully left and [code]1[/code] is fully right.
@export_range(0, 1) var origin_x : float = 0.5:
	set(val):
		origin_x = val
		_fix_childrend()
## The vertical offset of the ellipse's center.
## [br][br]
## [code]0[/code] is fully top and [code]1[/code] is fully bottom.
@export_range(0, 1) var origin_y : float = 0.5:
	set(val):
		origin_y = val
		_fix_childrend()

## The horizontal radius of the ellipse's center.
## [br][br]
## [code]0[/code] is [code]0[/code], [code]0.5[/code] is half of [member Control.size].x, and [code]1[/code] is [member Control.size].x.
@export_range(0, 1) var xRadius : float = 0.5:
	set(val):
		xRadius = val
		_fix_childrend()
## The vertical radius of the ellipse's center.
## [br][br]
## [code]0[/code] is [code]0[/code], [code]0.5[/code] is half of [member Control.size].y, and [code]1[/code] is [member Control.size].y.
@export_range(0, 1) var yRadius : float = 0.5:
	set(val):
		yRadius = val
		_fix_childrend()

@export_storage var _container_angles : PackedFloat32Array

func _ready() -> void:
	resized.connect(_fix_childrend)
	child_order_changed.connect(_childrend_changed)
	_childrend_changed()
	_fix_childrend()

func _childrend_changed() -> void:
	_container_angles.resize(_get_control_children().size())
	notify_property_list_changed()
	_fix_childrend()
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control))
	return ret
func _fix_childrend() -> void:
	var children := _get_control_children()
	
	for index : int in range(0, children.size()):
		var child : Control = children[index]
		if child: _fix_child(child, index)
func _fix_child(child : Control, index : int) -> void:
	if _container_angles.is_empty(): return
	child.reset_size()
	
	var child_size := child.get_combined_minimum_size()
	var child_pos := -(child_size * 0.5) + (Vector2(origin_x, origin_y) + (Vector2(xRadius, yRadius) * Vector2(cos(_container_angles[index]), sin(_container_angles[index])))) * size
	
	if child_pos.x < 0:
		child_pos.x = 0
	if child_pos.y < 0:
		child_pos.y = 0
	
	if child_pos.x + child_size.x > size.x:
		child_pos.x += size.x - (child_pos.x + child_size.x)
	if child_pos.y + child_size.y > size.y:
		child_pos.y += size.y - (child_pos.y + child_size.y)
	if child_pos.y + child_size.y > size.y:
		child_size.y = size.y - child_pos.y
	fit_child_in_rect(child, Rect2(child_pos, child_size))

func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary] = []
	ret.append({
		"name": "Angles",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_string": ""
	})
	ret.append({
		"name": "Degrees",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint_string": "deg_"
	})
	for i : int in range(0, _container_angles.size()):
		ret.append({
			"name": "deg_child_" + str(i),
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR,
		})
	
	ret.append({
		"name": "Radians",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint_string": "rad_"
	})
	for i : int in range(0, _container_angles.size()):
		ret.append({
			"name": "rad_child_" + str(i),
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR,
		})
	return ret
func _set(property: StringName, value: Variant) -> bool:
	var info := _get_property_info(property)
	if info.is_empty(): return false
	
	match info[1]:
		"deg":
			_container_angles[info[0]] = deg_to_rad(value)
		"rad":
			_container_angles[info[0]] = value
		_:
			return false
	
	_fix_child(_get_control_children()[info[0]], info[0])
	return true
func _get(property: StringName) -> Variant:
	var info := _get_property_info(property)
	if info.is_empty(): return null
	
	match info[1]:
		"deg":
			return rad_to_deg(_container_angles[info[0]])
		"rad":
			return _container_angles[info[0]]
	return null
func _get_property_info(property: StringName) -> Array:
	var strs : PackedStringArray = property.split("_")
	if (
		strs.size() == 3 &&
		strs[0] in ["deg", "rad"] &&
		strs[1] == "child" &&
		strs[2].is_valid_int()
		):
			var idx : int = int(strs[2])
			if 0 <= idx && idx < _container_angles.size():
				return [idx, strs[0]]
	return []


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return []
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return []
