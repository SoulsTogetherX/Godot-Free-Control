# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## Used to animate and hold the tabs for the [RouterSlide] node.


#region External Variables
## All shared info about this router
@export var router_info : RouterSlideInfo:
	set(val):
		if val != router_info:
			if router_info:
				router_info.changed_size.disconnect(_create_tabs)
				router_info.changed_tabs_template.disconnect(_create_tabs)
				router_info.changed_tabs_args.disconnect(_on_args_changed)
				router_info.changed_idx.disconnect(_on_index_changed)
			router_info = val
			if router_info:
				router_info.changed_size.connect(_create_tabs)
				router_info.changed_tabs_template.connect(_create_tabs)
				router_info.changed_tabs_args.connect(_on_args_changed)
				router_info.changed_idx.connect(_on_index_changed)
			
			if is_node_ready():
				_on_info_update()
#endregion


#region Private Variables
var _tabs : Array[BaseRouterSlideTab]
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_tabs()
#endregion


#region Private Methods (Construct/Deconstruct)
func _destroy_tabs() -> void:
	for tab : BaseRouterSlideTab in _tabs:
		if tab:
			tab.queue_free()
	_clear_tabs()
func _create_tabs() -> void:
	_destroy_tabs()
	if !router_info:
		return
	
	var tab_width : float = size.x / router_info.size()
	for i : int in router_info.size():
		var tab : BaseRouterSlideTab = (
			router_info.tab_template.instantiate()
			if router_info.tab_template
			else BaseRouterSlideTab.new()
		)
		tab.info = router_info.page_infos[i]
		tab.tab_pressed.connect(_on_tab_selected.bind(i))
		
		_tabs[i] = tab
		add_child(tab)
	_sort_tabs()
#endregion


#region Private Methods (Helper)
func _sort_tabs() -> void:
	if !router_info:
		return
	
	var tab_width : float = size.x / router_info.size()
	for i : int in router_info.size():
		var tab : BaseRouterSlideTab = _tabs[i]
		if !tab:
			continue
		
		fit_child_in_rect(
			tab,
			Rect2(Vector2(i * tab_width, 0), Vector2(tab_width, size.y))
		)
func _clear_tabs() -> void:
	_tabs.resize(router_info.size() if router_info else 0)
	_tabs.fill(null)
#endregion


#region Private Methods (Info Update)
func _on_info_update() -> void:
	if !router_info:
		_destroy_tabs()
		return
	
	_create_tabs()
	_on_index_changed(-1, router_info.get_index(), false)
func _on_index_changed(old_idx : int, new_idx : int, use_animation : bool) -> void:
	set_focus(old_idx, false, use_animation)
	set_focus(new_idx, true, use_animation)
#endregion


#region Private Methods (Tab Info Update)
func _on_tab_selected(idx : int) -> void:
	if !is_vaild_idx(idx) || router_info.page_infos[idx].is_disabled():
		return
	router_info.set_index(idx, true)
func _on_args_changed() -> void:
	for tab : BaseRouterSlideTab in _tabs:
		if tab:
			tab._on_args_changed()
#endregion


#region Public Methods (Set Value)
## Changes the disabled status of a tab give [param idx] page index.
func set_disable(idx : int, toggle : bool, use_animation : bool) -> void:
	if !is_vaild_idx(idx):
		return
	router_info.page_infos[idx].set_disabled(toggle, use_animation)
## Changes the focus status of a tab give [param idx] page index.
func set_focus(idx : int, toggle : bool, use_animation : bool) -> void:
	if !is_vaild_idx(idx):
		return
	router_info.page_infos[idx].set_focused(toggle, use_animation)
#endregion


#region Public Methods (Helper)
## Returns if the given [param idx] is vaild.
## [br][br]
## Also see [member page_infos].
func is_vaild_idx(idx : int) -> bool:
	return router_info && router_info.is_vaild_idx(idx)
#endregion
