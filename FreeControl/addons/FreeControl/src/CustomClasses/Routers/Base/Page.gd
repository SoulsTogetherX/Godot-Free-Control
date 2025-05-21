@tool
class_name Page extends Container
## A [Control] node for routers.

## A signal that is emited when this page enters a router display and finished animation.
@warning_ignore("unused_signal")
signal entered
## A signal that is emited before this page's enter animation begins playing.
@warning_ignore("unused_signal")
signal entering
## A signal that is emited when this page exits a router display and finished animation.
@warning_ignore("unused_signal")
signal exited
## A signal that is emited before this page's exit animation begins playing.
@warning_ignore("unused_signal")
signal exiting
## A signal that is manually emited to transfer events through it's attached router.
signal event_action(event_name : String, args : Variant)


## Emits the [signal event_action] signal.
func emit_event(event_name : String, args : Variant) -> void:
	event_action.emit(event_name, args)



func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		clip_contents = true
func _init() -> void:
	sort_children.connect(_sort_children)



func _sort_children() -> void:
	for child : Node in get_children():
		if child is Control: _update_child(child)
func _update_child(child : Control):
	var child_min_size := child.get_minimum_size()
	var result_size := child_min_size
	
	var set_pos : Vector2
	match child.size_flags_horizontal & ~SIZE_EXPAND:
		SIZE_FILL:
			result_size.x = max(result_size.x, size.x)
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_BEGIN:
			set_pos.x = 0
		SIZE_SHRINK_CENTER:
			set_pos.x = (size.x - result_size.x) * 0.5
		SIZE_SHRINK_END:
			set_pos.x = size.x - result_size.x
	match child.size_flags_vertical & ~SIZE_EXPAND:
		SIZE_FILL:
			result_size.y = max(result_size.y, size.y)
			set_pos.y = (size.y - result_size.y) * 0.5
		SIZE_SHRINK_BEGIN:
			set_pos.y = 0
		SIZE_SHRINK_CENTER:
			set_pos.y = (size.y - result_size.y) * 0.5
		SIZE_SHRINK_END:
			set_pos.y = size.y - result_size.y
	
	fit_child_in_rect(child, Rect2(set_pos, result_size))



func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
