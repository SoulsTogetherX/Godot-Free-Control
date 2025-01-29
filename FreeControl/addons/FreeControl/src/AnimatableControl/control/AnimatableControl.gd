# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableControl extends Container
## A container to be used for free transformation within a UI.

## This signal emits when one of the following properties change: scale, position,
## rotation, pivot_offset
signal transformation_changed

## The size mode this node's size will be bounded by.
enum SIZE_MODE {
	NONE = 0b00, ## This node's size is not bounded
	MIN = 0b01,  ## This node's size will be greater than or equal to this node's mount size
	MAX = 0b10,  ## This node's size will be less than or equal to this node's mount size
	EXACT = 0b11 ## This node's size will be the same as this node's mount size
}

## Controls how this node's size is bounded, according to the node's mount size
@export var size_mode : SIZE_MODE = SIZE_MODE.EXACT:
	set(val):
		if size_mode != val:
			size_mode = val
			notify_property_list_changed()
			_bound_size()
## Auto sets the pivot to be at some position percentage of the size.
@export var pivot_ratio : Vector2 = Vector2.ZERO:
	set(val):
		if pivot_ratio != val:
			pivot_ratio = val
			pivot_offset = size * val

var _mount : AnimatableMount
var _min_size : Vector2
var _ignore_resize : bool

func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is AnimatableMount:
		return []
	return ["This node only serves to be animatable within a UI. Please only attach as a child to a 'AnimatableMount' node."]
func _validate_property(property: Dictionary) -> void:
	if property.name in ["layout_mode", "anchors_preset"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "size":
		if size_mode == SIZE_MODE.EXACT:
			property.usage |= PROPERTY_USAGE_READ_ONLY
func _set(property: StringName, value: Variant) -> bool:
	if property in ["scale", "position", "rotation"]:
		transformation_changed.emit()
		_bound_size()
	elif property == "pivot_offset":
		pivot_ratio = pivot_offset / size
		transformation_changed.emit()
		_bound_size()
	return false

func _ready() -> void:
	if !resized.is_connected(_handle_resize):
		resized.connect(_handle_resize)
	if !sort_children.is_connected(_sort_children):
		sort_children.connect(_sort_children)
	if !tree_exited.is_connected(_on_tree_exit):
		tree_exited.connect(_on_tree_exit)
	if !tree_entered.is_connected(_on_tree_enter):
		tree_entered.connect(_on_tree_enter)
	if !item_rect_changed.is_connected(transformation_changed.emit):
		item_rect_changed.connect(transformation_changed.emit)
	
	_on_tree_enter()
func _on_tree_enter() -> void:
	_mount = (get_parent() as AnimatableMount)
	if _mount:
		if _mount.is_node_ready(): _bound_size()
		elif !_mount.ready.is_connected(_bound_size):
			_mount.ready.connect(_bound_size, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
		_mount._on_mount(self)
	_sort_children()
func _on_tree_exit() -> void:
	if _mount:
		_mount.queue_minimum_size_update()
		_mount._on_unmount(self)
		_mount = null

func _handle_resize() -> void:
	if _ignore_resize: return
	_ignore_resize = true
	_bound_size()
	_ignore_resize = false
func _sort_children() -> void:
	var _old_min_size := _min_size
	_min_size = Vector2.ZERO
	for child : Node in get_children():
		if child is Control:
			_min_size = _min_size.max(child.get_combined_minimum_size())
	
	if _min_size != _old_min_size:
		update_minimum_size()
		_resize_childrend()
		if _mount: _mount.queue_minimum_size_update()
	else: _resize_childrend()
func _resize_childrend() -> void:
	for child : Node in get_children():
		if child is Control:
			_resize_child(child)
func _resize_child(child : Control) -> void:
	var child_size := child.get_minimum_size()
	var set_pos : Vector2
	
	match size_flags_horizontal:
		SIZE_FILL:
			set_pos.x = 0
			child_size.x = max(child_size.x, size.x)
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_CENTER:
			set_pos.x = (size.x - child_size.x) * 0.5
		SIZE_SHRINK_END:
			set_pos.x = size.x - child_size.x
	match size_flags_vertical:
		SIZE_FILL:
			set_pos.y = 0
			child_size.y = max(child_size.y, size.y)
		SIZE_SHRINK_BEGIN:
			set_pos.y = 0
		SIZE_SHRINK_CENTER:
			set_pos.y = (size.y - child_size.y) * 0.5
		SIZE_SHRINK_END:
			set_pos.y = size.y - child_size.y
	
	fit_child_in_rect(child, Rect2(set_pos, child_size))
func _get_minimum_size() -> Vector2:
	return _min_size

func _bound_size() -> void:
	pivot_offset = size * pivot_ratio
	if !_mount : return
	
	var new_size : Vector2 = size
	if size_mode == SIZE_MODE.MAX:
		new_size = _mount.get_relative_size(self).min(size)
	elif size_mode == SIZE_MODE.MIN:
		new_size = _mount.get_relative_size(self).max(size)
	elif size_mode == SIZE_MODE.EXACT:
		new_size = _mount.get_relative_size(self)
	
	if new_size != size:
		size = new_size

## Gets the mount this node is currently a child to.[br]
## If this node is not a child to any [AnimatableMount] nodes, this returns [code]null[/code] instead.
func get_mount() -> AnimatableMount:
	return _mount

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
