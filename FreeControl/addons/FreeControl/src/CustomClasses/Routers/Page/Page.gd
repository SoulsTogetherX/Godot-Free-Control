# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name Page extends Container
## A standardized [Container] node for Routers to use, such as [RouterStack].

#region Signals
## Emits when an event is requested to the attached Router parent.
## [br][br]
## If this Router is a decedent of another [Page], connect that [Page]'s
## [method emit_event] with this [Signal].
signal event_action(event_name : String, args : Variant)

@warning_ignore("unused_signal")
## Emits when this page is added as a child and finished animation by a Router.
signal entered
@warning_ignore("unused_signal")
## Emits when this page is added as a child.
signal entering
@warning_ignore("unused_signal")
## Emits when this page is about to be removed as a child and finished animation by a Router.
signal exited
@warning_ignore("unused_signal")
## Emits when this page is marked to be removed as a child.
signal exiting
#endregion


#region Private Virtual Methods
func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		clip_contents = true

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
#endregion


#region Private Methods
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
#endregion


#region Public Methods
## Requests an event to the attached Router parent.
func emit_event(event_name : String, args : Variant) -> void:
	event_action.emit(event_name, args)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
