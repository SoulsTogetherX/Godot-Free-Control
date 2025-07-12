# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableControl extends Container
## A container to be used for free transformation within a UI.

#region Signals
## This signal emits when one of the following properties change: scale, position,
## rotation, pivot_offset
signal transformation_changed
## This signal emits when [member size_mode] is changed.
signal size_mode_changed
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
			size_mode_changed.emit()
			
			notify_property_list_changed()
## If [code]false[/code], then [member Control.pivot_offset] will not be changed according to
## [member pivot_ratio].
@export var auto_ratio : bool = true:
	set(val):
		if auto_ratio != val:
			auto_ratio = val
			_update_offsets()
## Auto sets the pivot to be at some position percentage of the size.
## [br][br]
## Also see [member auto_ratio].
@export var pivot_ratio : Vector2:
	set(val):
		if pivot_ratio != val:
			pivot_ratio = val
			_pivot_redirect = val
#endregion


#region Private Variables
@export_storage var _pivot_redirect : Vector2:
	set(val):
		_pivot_redirect = val
		_update_offsets()
#endregion


#region Private Virtual Methods
func _init() -> void:
	set_notify_local_transform(true)

func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size := Vector2.ZERO
	for child : Node in get_children():
		if child is Control:
			min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _validate_property(property: Dictionary) -> void:
	if !get_mount():
		return
	
	if property.name in ["layout_mode", "anchors_preset"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "size":
		if size_mode == SIZE_MODE.EXACT:
			property.usage |= PROPERTY_USAGE_READ_ONLY
func _set(property: StringName, value: Variant) -> bool:
	if property == &"pivot_offset":
		_pivot_redirect = (value / size).maxf(0)
		if !auto_ratio:
			pivot_offset = size * value
		
		return true
	return false

func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is AnimatableMount:
		return []
	return ["This node only serves to be animatable within a UI. Please only attach as a child to a 'AnimatableMount' node."]

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			transformation_changed.emit()
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()
		NOTIFICATION_RESIZED:
			_update_offsets()
		NOTIFICATION_READY:
			_update_offsets()
#endregion


#region Private Methods
func _update_offsets() -> void:
	if !auto_ratio:
		return
	
	pivot_ratio  = _pivot_redirect
	pivot_offset = _pivot_redirect * size

func _sort_children() -> void:
	for child : Node in get_children():
		if child is Control:
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
#endregion


#region Public Methods
## Returns the [AnimatableMount] node this [AnimatableControl] is a child of. Returns
## [code]null[/code] if this node is not a child of any mount. 
func get_mount() -> AnimatableMount:
	return get_parent_control() as AnimatableMount
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
