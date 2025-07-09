# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## The [Container] that holds and maintains all the tabs for [RouterSlide].

#region Signals
## Emited when a tab was interacted with by the user.
signal tab_pressed(idx : int)
#endregion


#region Private Variables
var _index : int = -1
var _tabs : Array[BaseRouterTab]
#endregion


#region Private Virtual Methods
func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2
	for child : Node in get_children():
		if child is Control:
			min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_position_components()
#endregion


#region Private Methods
func _clear_tabs() -> void:
	for tab : BaseRouterTab in _tabs:
		tab.queue_free()
	_tabs = []
func _create_tabs(tab_info : Array[RouterTabInfo], template : PackedScene) -> void:
	_clear_tabs()
	
	for idx : int in tab_info.size():
		var info := tab_info[idx]
		var tab : BaseRouterTab = template.instantiate() if template != null else BaseRouterTab.new()
		
		add_child(tab)
		_tabs.append(tab)
		
		tab.tab_selected.connect(tab_pressed.emit.bind(idx))
		tab.update_info(info)
	
	_position_components()

func _position_components() -> void:
	if _tabs.is_empty():
		return
	
	var tab_width : float = size.x / _tabs.size()
	for idx : int in _tabs.size():
		var tab := _tabs[idx]
		
		fit_child_in_rect(
			tab,
			Rect2(
				Vector2(tab_width * idx, 0),
				Vector2(tab_width, size.y)
			)
		)

func _get_tab(idx : int) -> BaseRouterTab:
	if 0 > idx || idx >= _tabs.size():
		return null
	return _tabs[idx]
#endregion


#region Public Methods
## Frees and recreates all tabs.
func refresh_tabs(
	tab_info : Array[RouterTabInfo],
	template : PackedScene,
	parent_args : Dictionary,
	margin_left : int,
	margin_top : int,
	margin_right : int,
	margin_bottom : int
) -> void:
	_create_tabs(tab_info, template)
	set_args(parent_args)
	set_margins(margin_left, margin_top, margin_right, margin_bottom)


## Sets the parent arguments for all tabs
func set_args(parent_args : Dictionary) -> void:
	for tab : BaseRouterTab in _tabs:
		tab.update_args(parent_args)
## Sets the margins for all tabs
func set_margins(
	margin_left : int,
	margin_top : int,
	margin_right : int,
	margin_bottom : int
) -> void:
	for tab : BaseRouterTab in _tabs:
		tab.margin_left = margin_left
		tab.margin_top = margin_top
		tab.margin_right = margin_right
		tab.margin_bottom = margin_bottom


## Disabled or enables a tab.
## [br][br]
## If [param animate] is [code]true[/code], the tab is expected to animate to a
## disabled state. Otherwise, it won't.
func toggle_disable(idx : int, disable : bool, animate : bool = true) -> void:
	var tab := _get_tab(idx)
	if !tab:
		return
	tab.toggle_disable(disable, animate)


## Focuses or unfocuses a tab.
## [br][br]
## If [param animate] is [code]true[/code], the tab is expected to animate to a
## disabled state. Otherwise, it won't.
func goto_index(idx : int, animate : bool = true) -> void:
	var tab : BaseRouterTab
	
	tab = _get_tab(_index)
	if tab:
		tab.toggle_focus(false, animate)
	tab = _get_tab(idx)
	if tab:
		tab.toggle_focus(true, animate)
	
	_index = idx
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
