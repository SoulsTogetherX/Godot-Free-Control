@tool
class_name CircularContainer extends Container

@export_range(0, 1) var origin_x : float = 0.5:
	set(val):
		origin_x = val
		_fix_childrend()
@export_range(0, 1) var origin_y : float = 0.5:
	set(val):
		origin_y = val
		_fix_childrend()

@export_range(0, 1) var xRadius : float = 1:
	set(val):
		xRadius = val
		_fix_childrend()
@export_range(0, 1) var yRadius : float = 1:
	set(val):
		yRadius = val
		_fix_childrend()

@export_storage var _angle_radians : PackedFloat32Array

func _ready() -> void:
	resized.connect(_fix_childrend)
	child_order_changed.connect(_childrend_changed)
	_fix_childrend()

func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control))
	return ret
func _childrend_changed() -> void:
	_angle_radians.resize(_get_control_children().size())
	notify_property_list_changed()
	_fix_childrend()
func _fix_childrend() -> void:
	var children := _get_control_children()
	
	for index in range(0, children.size()):
		_fix_child(children[index], index)
func _fix_child(child : Control, index : int) -> void:
	if _angle_radians.is_empty(): return
	
	child.reset_size()
	
	var child_size := child.get_combined_minimum_size()
	var child_pos := -(child_size * 0.5) + (Vector2(origin_x, origin_y) + (Vector2(xRadius, yRadius) * 0.5 * Vector2(cos(_angle_radians[index]), sin(_angle_radians[index])))) * size
	
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
		"hint_string": "angle_"
	})
	ret.append({
		"name": "Degrees",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint_string": "angle_deg_"
	})
	for i : int in range(0, _angle_radians.size()):
		ret.append({
			"name": "angle_deg_node_" + str(i),
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR,
		})
	
	
	ret.append({
		"name": "Radians",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint_string": "angle_rad_"
	})
	for i : int in range(0, _angle_radians.size()):
		ret.append({
			"name": "angle_rad_node_" + str(i),
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR,
		})
	
	return ret
func _set(property: StringName, value: Variant) -> bool:
	var info := _get_property_info(property)
	if info.is_empty(): return false
	
	match info[1]:
		"deg":
			_angle_radians[info[0]] = deg_to_rad(value)
		"rad":
			_angle_radians[info[0]] = value
		_:
			return false
	
	_fix_child(_get_control_children()[info[0]], info[0])
	return true
func _get(property: StringName) -> Variant:
	var info := _get_property_info(property)
	if info.is_empty(): return null
	
	match info[1]:
		"deg":
			return rad_to_deg(_angle_radians[info[0]])
		"rad":
			return _angle_radians[info[0]]
	
	return null
func _get_property_info(property: StringName) -> Array:
	var strs : PackedStringArray = property.split("_")
	if (
		strs.size() == 4 &&
		strs[0] == "angle" &&
		strs[1] in ["deg", "rad"] &&
		strs[2] == "node" &&
		strs[3].is_valid_int()
		):
			var idx : int = int(strs[3])
			if 0 <= idx && idx < _angle_radians.size():
				return [idx, strs[1]]
	return []
