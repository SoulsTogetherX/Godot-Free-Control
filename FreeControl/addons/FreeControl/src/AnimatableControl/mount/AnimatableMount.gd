# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
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
func _update_children_minimum_size() -> void:
	var _old_min_size := _min_size
	_min_size = Vector2.ZERO
	
	# Ensures size is the same as the largest size (of both axis) of children
	for child : AnimatableControl in get_children():
		if child: _min_size = _min_size.max(child.get_combined_minimum_size())
	
	if _old_min_size != _min_size:
		update_minimum_size()

func _ready() -> void:
	if !resized.is_connected(_handle_resize):
		resized.connect(_handle_resize)
	queue_minimum_size_update()
func _handle_resize() -> void:
	for child : AnimatableControl in get_children():
		if child: child._bound_size()

## Queues This mount to update it's size, size min, and all children, within the frame.[br]
## Cannot be called more than once in a single frame. Will be finished at the end of the frame.
func queue_minimum_size_update() -> void:
	# Aquires lock
	if _update_queued: return
	_update_queued = true
	
	# Does nothing if not inside tree.
	if is_inside_tree(): 
		# Updates children size
		call_deferred("call_deferred", "_update_children_minimum_size")
	
		# Releases lock at the start of next frame
		if is_inside_tree(): await get_tree().process_frame.connect(_relase_queue, CONNECT_ONE_SHOT)
func _relase_queue() -> void: _update_queued = false

## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being added as a child.
func _on_mount(control : AnimatableControl) -> void: pass
## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being removed as a child.
func _on_unmount(control : AnimatableControl) -> void: pass
## A helper function that should be used when creating your own mounts.[br]
## Returns size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2: return size

# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
