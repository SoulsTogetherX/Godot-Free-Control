# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name CircularContainer extends Container
## A container that positions children in a ellipse within the bounds of this node.

## Behavior the auto angle setter will exhibit.
enum BOUND_BEHAVIOR {
	NONE, ## No end bound for angles
	STOP, ## Angles, if exceeding the max, will be hard stopped at the max.
	LOOP, ## Angles, if exceeding the max, will loop back to the begining.
	MIRRIOR ## Angles, if exceeding the max, will bounce back and forth between the min and max angles.
}

## The horizontal offset of the ellipse's center.
## [br][br]
## [code]0[/code] is fully left and [code]1[/code] is fully right.
@export_range(0, 1) var origin_x : float = 0.5:
	set(val):
		origin_x = val
		queue_sort()
## The vertical offset of the ellipse's center.
## [br][br]
## [code]0[/code] is fully top and [code]1[/code] is fully bottom.
@export_range(0, 1) var origin_y : float = 0.5:
	set(val):
		origin_y = val
		queue_sort()

## The horizontal radius of the ellipse's center.
## [br][br]
## [code]0[/code] is [code]0[/code], [code]0.5[/code] is half of [member Control.size].x, and [code]1[/code] is [member Control.size].x.
@export_range(0, 1) var xRadius : float = 0.5:
	set(val):
		xRadius = val
		queue_sort()
## The vertical radius of the ellipse's center.
## [br][br]
## [code]0[/code] is [code]0[/code], [code]0.5[/code] is half of [member Control.size].y, and [code]1[/code] is [member Control.size].y.
@export_range(0, 1) var yRadius : float = 0.5:
	set(val):
		yRadius = val
		queue_sort()

@export_group("Angles")
## If [code]false[/code], the node will automatically write the angles of children.[br]
## If [code]true[/code], you will be required to manually input angles for each child.
@export var manual : bool = false:
	set(val):
		if manual != val:
			manual = val
			notify_property_list_changed()
			_calculate_angles()

## The behavior this node will have if the angle exceeds the max set angle in auto-mode.
## [br][br]
## See [member manual] and [member angle_end], 
var bound_behavior : BOUND_BEHAVIOR:
	set(val):
		if bound_behavior != val:
			bound_behavior = val
			notify_property_list_changed()
			_calculate_angles()
## If true, the nodes will be equal-distantantly placed from each on, between the start and end angles. Overides all other [member bound_behavior].
## [br][br]
## See [member manual], [member bound_behavior], [member angle_start], and [member angle_end].
var equal_distant : bool:
	set(val):
		if equal_distant != val:
			equal_distant = val
			notify_property_list_changed()
			_calculate_angles()

## The angle auto-mode will increment from.
## [br][br]
## See [member manual], [member bound_behavior], [member angle_start], and [member angle_end].
var angle_start : float = 0:
	set(val):
		if angle_start != val:
			angle_start = val
			_calculate_angles()
## The angle auto-mode will increment with.
## [br][br]
## See [member manual].
var angle_step : float = 10:
	set(val):
		if angle_step != val:
			angle_step = val
			_calculate_angles()
## The angle auto-mode will increment to.
## [br][br]
## See [member manual] and [member bound_behavior].
var angle_end : float = 360:
	set(val):
		if angle_end != val:
			angle_end = val
			_calculate_angles()

@export_storage var _container_angles : PackedFloat32Array
## The list of angles this ndoe uses to position each child, within the order they are positions in the tree.
var angles : PackedFloat32Array:
	set(val):
		_container_angles.resize(max(_get_control_children().size(), val.size()))
		
		for i in range(0, val.size()):
			_container_angles[i] = deg_to_rad(val[i])
		for i in range(val.size(), _container_angles.size()):
			_container_angles[i] = 0
		
		_fix_childrend()
	get:
		var ret : PackedFloat32Array
		ret.resize(_container_angles.size())
		
		for i in range(0, _container_angles.size()):
			ret[i] = rad_to_deg(_container_angles[i])
		return ret

func _ready() -> void:
	if !sort_children.is_connected(_fix_childrend):
		sort_children.connect(_fix_childrend)
	if !child_order_changed.is_connected(_childrend_changed):
		child_order_changed.connect(_childrend_changed)
	_childrend_changed()
	_fix_childrend()

func _childrend_changed() -> void:
	_calculate_angles()
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
	
	# Calculates child position
	var child_size := child.get_combined_minimum_size()
	var child_pos := -(child_size * 0.5) + (Vector2(origin_x, origin_y) + (Vector2(xRadius, yRadius) * Vector2(cos(_container_angles[index]), sin(_container_angles[index])))) * size
	
	# Keeps children in the rect's top-left boundards
	if child_pos.x < 0:
		child_pos.x = 0
	if child_pos.y < 0:
		child_pos.y = 0
	
	# Keeps children in the rect's bottom-right boundards
	if child_pos.x + child_size.x > size.x:
		child_pos.x += size.x - (child_pos.x + child_size.x)
	if child_pos.y + child_size.y > size.y:
		child_pos.y += size.y - (child_pos.y + child_size.y)
	if child_pos.y + child_size.y > size.y:
		child_size.y = size.y - child_pos.y
	
	fit_child_in_rect(child, Rect2(child_pos, child_size))

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary]
	
	if manual:
		properties.append({
			"name": "angles",
			"type": TYPE_PACKED_FLOAT32_ARRAY,
			"usage" : PROPERTY_USAGE_EDITOR
		})
	else:
		var unbounded = PROPERTY_USAGE_READ_ONLY if bound_behavior == BOUND_BEHAVIOR.NONE else 0
		var allow_step = PROPERTY_USAGE_READ_ONLY if equal_distant && bound_behavior == BOUND_BEHAVIOR.STOP else 0
		
		properties.append({
			"name": "bound_behavior",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(BOUND_BEHAVIOR.keys()),
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "equal_distant",
			"type": TYPE_BOOL,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "Values",
			"type": TYPE_NIL,
			"usage" : PROPERTY_USAGE_SUBGROUP,
			"hint_string": ""
		})
		properties.append({
			"name": "angle_start",
			"type": TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "angle_step",
			"type": TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT | allow_step
		})
		properties.append({
			"name": "angle_end",
			"type": TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT | unbounded
		})
	
	return properties
func _property_can_revert(property: StringName) -> bool:
	match property:
		"bound_behavior":
			return bound_behavior != BOUND_BEHAVIOR.NONE
		"equal_distant":
			return equal_distant
		"angle_start":
			return angle_start != 0
		"angle_step":
			return angle_step != 10
		"angle_end":
			return angle_end != 360
	
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		"bound_behavior":
			return BOUND_BEHAVIOR.NONE
		"equal_distant":
			return false
		"angle_start":
			return 0
		"angle_step":
			return 10
		"angle_end":
			return 360
	
	return null

func _calculate_angles() -> void:
	if manual: return
	
	var count := _get_control_children().size()
	_container_angles.resize(count)
	
	var start := deg_to_rad(angle_start)
	var end := deg_to_rad(angle_end)
	
	var step : float
	if equal_distant:
		if count != 0: step = deg_to_rad((angle_end - angle_start) / (count - 1))
	else:
		step = deg_to_rad(angle_step)
	
	var inc_func : Callable
	if equal_distant || bound_behavior == BOUND_BEHAVIOR.NONE:
		inc_func = func(i : int): return (i * step) + start
	elif bound_behavior == BOUND_BEHAVIOR.STOP:
		inc_func = func(i : int): return min(i * step, end) + start
	elif bound_behavior == BOUND_BEHAVIOR.LOOP:
		inc_func = func(i : int): return fmod(i * step, end) + start
	elif bound_behavior == BOUND_BEHAVIOR.MIRRIOR:
		inc_func = func(i : int): return abs(fmod((i * step) - end, 2 * end) - end) + start
	
	for i : int in range(0, _container_angles.size()):
		_container_angles[i] = fposmod(inc_func.call(i), TAU)
	_fix_childrend()

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return []
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return []

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
