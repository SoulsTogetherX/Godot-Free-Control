# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableControl extends Container
## A container to be used for free transformation within a UI.

#region Signals
## This signal emits when one of the following properties change: scale, position,
## rotation, pivot_offset
signal transformation_changed
#endregion


#region Enums
## The size mode this node's size will be bounded by.
enum SIZE_MODE {
	NONE = 0b00, ## This node's size is not bounded
	MIN = 0b01,  ## This node's size will be greater than or equal to this node's mount size
	MAX = 0b10,  ## This node's size will be less than or equal to this node's mount size
	EXACT = 0b11 ## This node's size will be the same as this node's mount size
}
#endregion


#region External Variables
## Controls how this node's size is bounded, according to the node's mount size
@export var size_mode : SIZE_MODE = SIZE_MODE.EXACT:
	set(val):
		if size_mode != val:
			size_mode = val
			if _mount:
				_mount.update_minimum_size()
			_bound_size()
			notify_property_list_changed()
## Auto sets the pivot to be at some position percentage of the size.
@export var pivot_ratio : Vector2:
	set(val):
		if pivot_ratio != val:
			pivot_ratio = val
			pivot_offset = size * val
#endregion


#region Private Variables
var _mount : AnimatableMount
#endregion


#region Virtual Methods
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
		if is_node_ready() && size > Vector2.ZERO && pivot_offset != value:
			pivot_ratio = pivot_offset / size
			transformation_changed.emit()
	return false

func _init() -> void:
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
func _on_tree_enter() -> void:
	_mount = (get_parent() as AnimatableMount)
	if _mount:
		_mount._on_mount(self)
func _on_tree_exit() -> void:
	if _mount:
		_mount._on_unmount(self)
		_mount = null
#endregion


#region Private Methods
func _handle_resize() -> void:
	_bound_size()
	_update_pivot()
func _update_pivot() -> void:
	set_pivot_offset(pivot_ratio * size)
	transformation_changed.emit()
func _sort_children() -> void:
	for child : Control in _get_control_children():
		_resize_child(child)
func _resize_child(child : Control) -> void:
	var child_size := child.get_combined_minimum_size()
	var set_pos : Vector2
	
	match child.size_flags_horizontal & ~SIZE_EXPAND:
		SIZE_FILL:
			set_pos.x = 0
			child_size.x = max(child_size.x, size.x)
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_CENTER:
			set_pos.x = (size.x - child_size.x) * 0.5
		SIZE_SHRINK_END:
			set_pos.x = size.x - child_size.x
	match child.size_flags_vertical & ~SIZE_EXPAND:
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
	if clip_children: return Vector2.ZERO
	
	var min_size := Vector2.ZERO
	for child : Control in _get_control_children():
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _bound_size() -> void:
	if !_mount: return
	
	var new_size : Vector2 = size
	if size_mode == SIZE_MODE.MAX:
		new_size = _mount.get_relative_size(self).min(size)
	elif size_mode == SIZE_MODE.MIN:
		new_size = _mount.get_relative_size(self).max(size)
	elif size_mode == SIZE_MODE.EXACT:
		new_size = _mount.get_relative_size(self)
	
	if new_size != size:
		size = new_size

func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control && child.visible))
	return ret
#endregion


#region Public Methods
## Gets the mount this node is currently a child to.[br]
## If this node is not a child to any [AnimatableMount] nodes, this returns [code]null[/code] instead.
func get_mount() -> AnimatableMount:
	return _mount
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
