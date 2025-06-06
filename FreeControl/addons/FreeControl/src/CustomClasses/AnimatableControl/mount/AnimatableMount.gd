# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableMount extends Control
## Used as a mount for size consistency between children [AnimatableControl] nodes.

## Emits before children are sorted
signal pre_sort_children
## Emits after children have been sorted
signal sort_children

var _min_size : Vector2

func _get_configuration_warnings() -> PackedStringArray:
	for child : Node in get_children():
		if child is AnimatableControl: return []
	return ["This node has no 'AnimatableControl' nodes as children"]
func _get_minimum_size() -> Vector2:
	if clip_children: return Vector2.ZERO
	_update_children_minimum_size()
	return _min_size
func _update_children_minimum_size() -> void:
	_min_size = Vector2.ZERO
	
	# Ensures size is the same as the largest size (of both axis) of children
	for child : Node in get_children():
		if child is AnimatableControl:
			if child.size_mode & child.SIZE_MODE.MIN:
				_min_size = _min_size.max(child.get_combined_minimum_size())

func _init() -> void:
	resized.connect(_sort_children, CONNECT_DEFERRED)
	size_flags_changed.connect(_sort_children, CONNECT_DEFERRED)
func _sort_children() -> void:
	pre_sort_children.emit()
	for child : Node in get_children():
		if child is AnimatableControl:
			child._bound_size()
	sort_children.emit()

## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being added as a child.
func _on_mount(control : AnimatableControl) -> void: pass
## A virtual helper function that should be used when creating your own mounts.[br]
## Is called upon an [AnimatableControl] being removed as a child.
func _on_unmount(control : AnimatableControl) -> void: pass
## A helper function that should be used when creating your own mounts.[br]
## Returns size of this mount.
func get_relative_size(control : AnimatableControl) -> Vector2: return size

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
