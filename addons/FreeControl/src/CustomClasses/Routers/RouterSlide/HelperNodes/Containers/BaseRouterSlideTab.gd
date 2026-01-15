# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name BaseRouterSlideTab extends Container
## Used as a base for tabs used by [RouterSlide].


#region Signals
## Emitted when this tab is pressed
signal tab_pressed
#endregion


#region External Variables
## All shared info about this router
var info : RouterSlidePageInfo:
	set(val):
		if info != val:
			if info:
				info.changed_tabs_args.disconnect(_on_args_changed)
				info.changed_disabled.disconnect(_on_focus_changed)
				info.changed_focus.disconnect(_on_disabled_changed)
			info = val
			if info:
				info.changed_tabs_args.connect(_on_args_changed)
				info.changed_disabled.connect(_on_focus_changed)
				info.changed_focus.connect(_on_disabled_changed)
			
			if is_node_ready():
				_on_info_update()
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_on_sort_children()
#endregion


#region Custom Virtual Methods
## A virtual method that will be called whenever the parent or this node's
## tab arguments are changed.
## [br][br]
## Also see: [method get_args], [method get_tab_args], and [method get_parent_args].
func _on_args_changed() -> void:
	pass
## A virtual method that will be called whenever this tab's focus status
## changes.
## [br][br]
## Also see: [method is_focused].
func _on_focus_changed(use_animation : bool) -> void:
	pass
## A virtual method that will be called whenever this tab's focus disabled
## changes.
## [br][br]
## Also see: [method is_disabled].
func _on_disabled_changed(use_animation : bool) -> void:
	pass
#endregion


#region Private Methods (Helper)
func _get_minimum_size() -> Vector2:
	if clip_children:
		return Vector2.ZERO
	var min_size := Vector2.ZERO
	
	for child : Node in get_children():
		if child is Control:
			min_size = min_size.max(child.get_combined_minimum_size())
	return min_size
func _on_sort_children() -> void:
	for child : Node in get_children():
		if child is Control:
			fit_child_in_rect(child, Rect2(Vector2.ZERO, size))
#endregion


#region Private Methods (Info Update)
func _on_info_update() -> void:
	if !info:
		return
	
	_on_args_changed()
	_on_focus_changed(false)
	_on_disabled_changed(false)
#endregion


#region Public Methods (Signaling)
## Emits the signal [signal tab_pressed]. It is recommended to call this
## method when tapped.
func emit_pressed() -> void:
	tab_pressed.emit()
#endregion


#region Public Methods (State Accessor)
## Returns if this tab is currently focused.
func is_focused() -> bool:
	return info && info._focused
## Returns if this tab is currently disabled.
func is_disabled() -> bool:
	return info && info._disabled
#endregion


#region Public Methods (Arguments)
## Returns all tab arguments this tab uses.
func get_args() -> Dictionary:
	return info.get_args()
## Returns all tab arguments associated with this particular tab.
func get_tab_args() -> Dictionary:
	return info.get_tab_args()
## Returns all tab arguments of the parent [RouterSlide] node.
func get_parent_args() -> Dictionary:
	return info.get_parent_args()
#endregion
