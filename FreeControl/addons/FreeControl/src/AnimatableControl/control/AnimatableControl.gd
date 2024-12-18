@tool
class_name AnimatableControl extends Container
## A control to be used for free transformation within a UI

var _mount : AnimatableMount
var _min_size : Vector2

## A more portable method of editing the [member pivot_offset] via a ratio
## [br][br]
## An input of [code]Vector2(0.5, 0.5)[/code] will put the [member pivot_offset] in the middle of the object
@export var pivot_ratio : Vector2 = Vector2(0.5, 0.5):
	get:
		return pivot_offset / size
	set(val):
		pivot_offset = val * size

func _validate_property(property: Dictionary) -> void:
	if property.name in ["size", "layout_mode", "anchors_preset"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is AnimatableMount:
		return []
	return ["This node only serves to be animatable within a UI. Please only attach as a child to a 'AnimatableMount' node."]

func _ready() -> void:
	if !sort_children.is_connected(_sort_children):
		sort_children.connect(_sort_children, CONNECT_PERSIST)
	if !resized.is_connected(_on_resize):
		resized.connect(_on_resize, CONNECT_PERSIST)
	if !tree_entered.is_connected(_on_tree_enter):
		tree_entered.connect(_on_tree_enter, CONNECT_PERSIST)
	if !tree_exited.is_connected(_on_tree_exit):
		tree_exited.connect(_on_tree_exit, CONNECT_PERSIST)
	
	_on_tree_enter()

func _on_tree_enter() -> void:
	_mount = (get_parent() as AnimatableMount)
	if _mount:
		_mount.grow_min_size(_get_children_minimum_size())
		layout_mode = 0
		set_anchors_preset(Control.PRESET_FULL_RECT)
		call_deferred("set_position", Vector2.ZERO)
func _on_tree_exit() -> void:
	if _mount:
		_mount.update_children_min()
		_mount = null

func _on_resize() -> void:
	size = _min_size
func _sort_children() -> void:
	update_minimum_size()
	for child : Control in get_children():
		fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
func _get_children_minimum_size() -> Vector2:
	var min : Vector2
	for child : Control in get_children():
		min = min.max(child.get_combined_minimum_size())
	return min
func _get_minimum_size() -> Vector2:
	var _min_old := _min_size
	_min_size = _get_children_minimum_size()
	if _min_old != _min_size && _mount:
		_mount.update_children_min()
	return _min_size
