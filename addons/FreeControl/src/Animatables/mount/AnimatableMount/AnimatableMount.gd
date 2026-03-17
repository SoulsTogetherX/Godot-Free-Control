# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
@icon("uid://daxpji6uv1g46")
class_name AnimatableMount extends Control
## Used as a mount for size consistency between children [AnimatableControl] nodes.

#region Signals
## Emits before children are sorted
signal pre_sort_children
## Emits after children have been sorted
signal sort_children
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
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var _min_size := Vector2.ZERO
	for child : Node in get_children():
		if child is AnimatableControl && child.is_visible_in_tree():
			_min_size = _min_size.max(child.get_combined_minimum_size())
	
	return _min_size

func _get_configuration_warnings() -> PackedStringArray:
	for child : Node in get_children():
		if child is AnimatableControl:
			return []
	return ["This node has no 'AnimatableControl' nodes as children"]

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY:
			_add_all_children()
		NOTIFICATION_RESIZED, NOTIFICATION_THEME_CHANGED, NOTIFICATION_VISIBILITY_CHANGED:
			queue_sort()
#endregion


#region Public Virtual Methods
## See [Node.add_child].
func add_child(child : Node, force_readable_name: bool = false, internal: InternalMode = 0) -> void:
	super(child, force_readable_name, internal)
	
	var animatable := child as AnimatableControl
	if !animatable:
		return
	
	_connect_animatable(animatable)
	update_minimum_size()
	queue_sort()
## See [Node.remove_child].
func remove_child(child : Node) -> void:
	super(child)
	
	var animatable := child as AnimatableControl
	if !animatable:
		return
	
	_disconnect_animatable(animatable)
	update_minimum_size()
	queue_sort()
#endregion


#region Private Methods (Sort)
func _sort_children() -> void:
	if !is_visible_in_tree():
		return
	
	propagate_notification(NOTIFICATION_PRE_SORT_CHILDREN)
	pre_sort_children.emit()
	
	for child : Node in get_children():
		if child is AnimatableControl:
			_sort_child(child)
		elif child is Control:
			fit_child_in_rect(child, Rect2(Vector2.ZERO, size), false)
	
	propagate_notification(NOTIFICATION_SORT_CHILDREN)
	sort_children.emit()
	_queued_sort = false
func _sort_child(child : AnimatableControl) -> void:
	match child.size_mode:
		AnimatableControl.SIZE_MODE.MAX:
			child.size = size.min(child.size)
		AnimatableControl.SIZE_MODE.MIN:
			child.size = size.max(child.size)
		AnimatableControl.SIZE_MODE.EXACT:
			child.size = size
#endregion


#region Private Methods (Signal Connection)
func _connect_animatable(animatable : AnimatableControl) -> void:
	animatable.resized.connect(queue_sort)
	animatable.size_flags_changed.connect(queue_sort)
	
	animatable.size_mode_changed.connect(_update_children)
	animatable.minimum_size_changed.connect(_update_children)
	animatable.visibility_changed.connect(_update_children)
func _disconnect_animatable(animatable : AnimatableControl) -> void:
	animatable.resized.disconnect(queue_sort)
	animatable.size_flags_changed.disconnect(queue_sort)
	
	animatable.size_mode_changed.disconnect(_update_children)
	animatable.minimum_size_changed.disconnect(_update_children)
	animatable.visibility_changed.disconnect(_update_children)

func _add_all_children() -> void:
	for child : Node in get_children():
		var animatable := child as AnimatableControl
		if !animatable:
			continue
		_connect_animatable(animatable)
#endregion


#region Private Methods (Helper)
func _update_children() -> void:
	update_minimum_size()
	queue_sort()
#endregion


#region Public Methods
## Queue resort of the contained children. This is called automatically anyway,
## but can be called upon request.
## [br][br]
## [b]NOTE[/b]: This will be ignored if not visible in tree.
## See [CanvasItem.is_visible_in_tree]
func queue_sort() -> void:
	if _queued_sort:
		return
	
	call_deferred("_sort_children")
	_queued_sort = true

## Fit a child control in a given rect. This is mainly a helper for creating custom container classes.
func fit_child_in_rect(child: Control, rect: Rect2, perserve_transform : bool = false) -> void:
	if !child:
		push_error("Parameter \"p_child\" is null.")
		return
	if child.get_parent() != self:
		push_error("Condition \"p_child->get_parent() != this\" is true.")
		return
	
	if !perserve_transform:
		child.scale = Vector2.ONE
		child.pivot_offset = Vector2.ZERO
		child.rotation = 0
	
	child.position = rect.position
	child.size = rect.size
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
