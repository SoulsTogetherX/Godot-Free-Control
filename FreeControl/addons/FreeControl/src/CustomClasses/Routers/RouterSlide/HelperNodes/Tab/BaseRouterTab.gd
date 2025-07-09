# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name BaseRouterTab extends Container
## The base class for all tabs used by [RouterSlide].


#region Signals
## Emited when this tab was interacted with by the user.
## [br][br]
## Also see [method toggle_disable]. 
signal tab_selected
#endregion


#region External Variables
@export var margin_left : int:
	set(val):
		if margin_left != val:
			margin_left = val
			
			queue_sort()
@export var margin_top : int:
	set(val):
		if margin_top != val:
			margin_top = val
			
			queue_sort()
@export var margin_right : int:
	set(val):
		if margin_right != val:
			margin_right = val
			
			queue_sort()
@export var margin_bottom : int:
	set(val):
		if margin_bottom != val:
			margin_bottom = val
			
			queue_sort()
#endregion


#region Private Variables
var _hold_button : HoldButton

var _info : RouterTabInfo
var _parent_args : Dictionary

var _focused : bool
#endregion


#region Private Virtual Methods
func _init() -> void:
	_hold_button = HoldButton.new()
	_hold_button.press_vaild.connect(tab_selected.emit)
	
	add_child(_hold_button)
	_hold_button.move_to_front()

func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control:
			min_size = min_size.max(child.get_combined_minimum_size())
	
	return min_size

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_on_sort_children()
#endregion


#region Custom Virtual Methods
## This is a virtual method called when this tab's arguments are set or changed.
## [br][br]
## Also see [method update_args]. 
func _args_updated() -> void:
	pass
## This is a virtual method called when this tab is focused or unfocused.
## The parameter [param animate] is [code]true[/code] when an animation is requested.
## [br][br]
## Also see [method toggle_focus]. 
func _on_focus_updated(focused : bool, animate : bool) -> void:
	pass
## This is a virtual method called when this tab is disabled or enabled.
## The parameter [param animate] is [code]true[/code] when an animation is requested.
## [br][br]
## Also see [method toggle_disable]. 
func _on_disable_updated(disabled : bool, animate : bool) -> void:
	pass
#endregion


#region Private Methods
func _on_sort_children() -> void:
	var child_rect := Rect2(
		Vector2(margin_left, margin_top),
		size - Vector2(margin_right, margin_bottom)
	)
	
	for child : Node in get_children():
		if child is Control:
			fit_child_in_rect(child, child_rect)
	fit_child_in_rect(_hold_button, Rect2(Vector2.ZERO, size))

func _disabled_updated() -> void:
	if _info.disabled != is_disabled():
		toggle_disable(_info.disabled, true)
#endregion


#region Public Methods
## Updates the [RouterTabInfo] assocated with this tab.
func update_info(info : RouterTabInfo) -> void:
	if _info && _info.disabled_changed.is_connected(_disabled_updated):
		_info.disabled_changed.disconnect(_disabled_updated)
	if _info && _info.arguments_changed.is_connected(_args_updated):
		_info.arguments_changed.disconnect(_args_updated)
	
	_info = info
	
	toggle_disable(_info.disabled, false)
	
	_info.disabled_changed.connect(_disabled_updated)
	_info.arguments_changed.connect(_args_updated)
	
	_disabled_updated()
	_args_updated()
## Sets the parent arguments of this tab.
## [br][br]
## Also see [method get_args]. 
func update_args(parent_args : Dictionary) -> void:
	_parent_args = parent_args
	_args_updated()


## Toggles the focus of this tab.
func toggle_focus(focus : bool, animate : bool) -> void:
	if _focused == focus:
		return
	
	_focused = focus
	_on_focus_updated(focus, animate)
## Toggles the disabled status of this tab.
func toggle_disable(disable : bool, animate : bool) -> void:
	if is_disabled() == disable:
		return
	
	_hold_button.disabled = disable
	_info.disabled = disable
	_on_disable_updated(disable, animate)


## Returns the current args of this tab.
## [br][br]
## [b]NOTE[/b]: parent_args (set by [method update_args]) will be used as a base
## and overwriten by the arguments in the [RouterTabInfo] assocated with this tab,
## then returned by this method.
func get_args() -> Dictionary:
	if !_info:
		return _parent_args
	return _parent_args.merged(_info.args, true)
## Returns the focused status of this tab.
func is_focused() -> bool:
	return _focused
## Returns the disabled status of this tab.
func is_disabled() -> bool:
	return _hold_button.disabled
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
