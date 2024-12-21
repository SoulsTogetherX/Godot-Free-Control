@tool
class_name AnimatableMount extends Control
## Used as a mount for size consistency between children [AnimatableControl] nodes.

var _min_size : Vector2
var _update_queued : bool

func _get_configuration_warnings() -> PackedStringArray:
	for child : AnimatableControl in get_children():
		if child: return []
	return ["This node has no 'AnimatableControl' nodes as children"]
func _get_minimum_size() -> Vector2:
	return _min_size

func _ready() -> void:
	if !resized.is_connected(_handle_resize):
		resized.connect(_handle_resize)
func _handle_resize() -> void:
	for child : AnimatableControl in get_children():
		if child: child._bound_size()

func queue_minimum_size_update() -> void:
	if _update_queued: return
	_update_queued = true
	
	call_deferred("call_deferred", "_update_children_minimum_size")
	if is_inside_tree(): await get_tree().process_frame.connect(_relase_queue, CONNECT_ONE_SHOT)
	else: call_deferred("_relase_queue")
func _relase_queue() -> void: _update_queued = false

func _update_children_minimum_size() -> void:
	var _old_min_size := _min_size
	_min_size = Vector2.ZERO
	for child : AnimatableControl in get_children():
		if child: _min_size = _min_size.max(child.get_combined_minimum_size())
	
	if _old_min_size != _min_size:
		update_minimum_size()

## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being added as a child.
func _on_mount(control : AnimatableControl) -> void: pass
## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being removed as a child.
func _on_unmount(control : AnimatableControl) -> void: pass
## A helper function that should be used when creating your own mounts.[br]
## Returns size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2: return size
