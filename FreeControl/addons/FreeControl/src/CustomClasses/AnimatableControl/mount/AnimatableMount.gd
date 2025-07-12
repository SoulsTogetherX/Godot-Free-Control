# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableMount extends Control
## Used as a mount for size consistency between children [AnimatableControl] nodes.

#region Signals
## Emits before children are sorted
signal pre_sort_children
## Emits after children have been sorted
signal sort_children
#endregion


#region Enums
const SIZE_MODE = AnimatableControl.SIZE_MODE
#endregion


#region Constants
## Notification just before children are going to be sorted, in case there's something to process beforehand.
const NOTIFICATION_PRE_SORT_CHILDREN := 50
## Notification for when sorting the children, it must be obeyed immediately.
const NOTIFICATION_SORT_CHILDREN := 51
#endregion


#region Private Variables
var _queued_sort : bool
#endregion


#region Private Virtual Methods
func _ready() -> void:
	_add_all_children()

func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var _min_size := Vector2.ZERO
	
	# Ensures size is the same as the largest size (of both axis) of children
	for child : Node in get_children():
		if child is AnimatableControl:
			if child.size_mode & child.SIZE_MODE.MIN:
				_min_size = _min_size.max(child.get_combined_minimum_size())
	return _min_size

func _get_configuration_warnings() -> PackedStringArray:
	for child : Node in get_children():
		if child is AnimatableControl:
			return []
	return ["This node has no 'AnimatableControl' nodes as children"]

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_THEME_CHANGED:
			queue_sort()
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				queue_sort()
#endregion


#region Public Virtual Methods
func add_child(child : Node, force_readable_name: bool = false, internal: InternalMode = 0) -> void:
	super(child, force_readable_name, internal)
	
	var animatable := child as AnimatableControl
	if !animatable:
		return
		
	animatable.transformation_changed.connect(_on_transformation_changed)
	
	animatable.resized.connect(queue_sort)
	animatable.size_mode_changed.connect(queue_sort)
	animatable.size_flags_changed.connect(queue_sort)
	
	animatable.minimum_size_changed.connect(_child_minsize_changed)
	animatable.visibility_changed.connect(_child_minsize_changed)

	update_minimum_size()
	queue_sort()
func remove_child(child : Node) -> void:
	super(child)
	
	var animatable := child as AnimatableControl
	if !animatable:
		return
		
	animatable.transformation_changed.disconnect(_on_transformation_changed)
	
	animatable.resized.disconnect(queue_sort)
	animatable.size_mode_changed.disconnect(queue_sort)
	animatable.size_flags_changed.disconnect(queue_sort)
	
	animatable.minimum_size_changed.disconnect(_child_minsize_changed)
	animatable.visibility_changed.disconnect(_child_minsize_changed)

	update_minimum_size()
	queue_sort()
func move_child(child : Node, to_index: int) -> void:
	super(child, to_index)
	if !(child is AnimatableControl):
		return
	
	update_minimum_size()
	queue_sort()
#endregion


#region Custom Virtual Methods
## A helper function that should be used when creating your own mounts.[br]
## Returns size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2:
	return size
## A helper function that should be used when creating your own mounts.[br]
## Is called when the [member Control.scale], [member Control.position],
## [member Control.rotation], or [member Control.pivot_offset] of a child
## [Control AnimatableControl] has changed.
func _on_transformation_changed() -> void:
	return
#endregion


#region Private Methods
func _sort_children() -> void:
	propagate_notification(NOTIFICATION_PRE_SORT_CHILDREN)
	pre_sort_children.emit()
	
	for child : Node in get_children():
		if child is AnimatableControl:
			_sort_child(child)
	
	propagate_notification(NOTIFICATION_SORT_CHILDREN)
	sort_children.emit()
	_queued_sort = false
func _sort_child(child : AnimatableControl) -> void:
	match child.size_mode:
		SIZE_MODE.MAX:
			child.size = get_relative_size(child).min(child.size)
		SIZE_MODE.MIN:
			child.size = get_relative_size(child).max(child.size)
		SIZE_MODE.EXACT:
			child.size = get_relative_size(child)


func _add_all_children() -> void:
	for child : Node in get_children():
		var animatable := child as AnimatableControl
		if !animatable:
			continue
		
		if !animatable.transformation_changed.is_connected(_on_transformation_changed):
			animatable.transformation_changed.connect(_on_transformation_changed)
		
		if !animatable.resized.is_connected(queue_sort):
			animatable.resized.connect(queue_sort)
		if !animatable.size_mode_changed.is_connected(queue_sort):
			animatable.size_mode_changed.connect(queue_sort)
		if !animatable.size_flags_changed.is_connected(queue_sort):
			animatable.size_flags_changed.connect(queue_sort)
			
		if !animatable.minimum_size_changed.is_connected(_child_minsize_changed):
			animatable.minimum_size_changed.connect(_child_minsize_changed)
		if !animatable.visibility_changed.is_connected(_child_minsize_changed):
			animatable.visibility_changed.connect(_child_minsize_changed)

func _child_minsize_changed() -> void:
	update_minimum_size()
	queue_sort()
#endregion


#region Public Methods
func queue_sort() -> void:
	if !is_node_ready() || !is_inside_tree() || _queued_sort:
		return
	
	call_deferred("_sort_children")
	_queued_sort = true
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
