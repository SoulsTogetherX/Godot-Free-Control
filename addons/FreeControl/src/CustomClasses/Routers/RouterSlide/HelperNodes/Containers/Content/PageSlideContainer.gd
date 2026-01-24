# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## Used to load and hold the pages for the [RouterSlide] node.


#region Enums
## An Enum related to how this node will lazy-initiated [Page]s.
const PAGE_LOAD_MODE = RouterSlideInfo.PAGE_LOAD_MODE

## An Enum related to how this node will hide already initiated [Page]s that
## are outside of visible space.
const PAGE_HIDE_MODE = RouterSlideInfo.PAGE_HIDE_MODE
#endregion


#region External Variables
## All shared info about this router
@export var router_info : RouterSlideInfo:
	set(val):
		if router_info != val:
			if router_info:
				router_info.changed_hide_mode.disconnect(_on_hide_mode_changed)
				router_info.changed_load_mode.disconnect(_on_load_mode_changed)
				router_info.changed_size.disconnect(_on_size_changed)
				
				for info : RouterSlidePageInfo in router_info.page_infos:
					if info:
						info.changed_page_scene.disconnect(_on_page_changed)
						info.changed_page_idx.disconnect(_on_changed_page_idx)
				
			router_info = val
			if router_info:
				router_info.changed_hide_mode.connect(_on_hide_mode_changed)
				router_info.changed_load_mode.connect(_on_load_mode_changed)
				router_info.changed_size.connect(_on_size_changed)
				
				for info : RouterSlidePageInfo in router_info.page_infos:
					if info:
						info.changed_page_scene.connect(_on_page_changed)
						info.changed_page_idx.connect(_on_changed_page_idx)
			
			if is_node_ready():
				_on_info_update()
			
#endregion


#region Private Variables
var _pages : Array[Page]

var _page_reorder_queue : Array[int]
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			_on_info_update()
		NOTIFICATION_SORT_CHILDREN:
			_on_sort_children()
#endregion


#region Private Methods (Info Update)
func _on_info_update() -> void:
	if !router_info:
		return
	
	_on_hide_mode_changed()
	_on_size_changed()
func _on_load_mode_changed() -> void:
	if router_info.page_load_mode == PAGE_LOAD_MODE.ALL:
		_bridge_call(0, router_info.size() - 1, _get_toggle_callable(true, PAGE_HIDE_MODE.HIDE_DISABLE))
		_bridge_call(0, router_info.size() - 1, _toggle_load.bind(true))
		return
	_refresh_offscreen_pages()
func _on_hide_mode_changed() -> void:
	_refresh_offscreen_pages()
func _on_size_changed() -> void:
	_pages.resize(router_info.size())
	queue_sort()
func _on_page_changed(page_idx : int) -> void:
	refresh_page(page_idx)
func _on_changed_page_idx(old_index : int, new_index : int) -> void:
	if _page_reorder_queue.is_empty():
		call_deferred("_page_idx_changed_queued")
	
	_page_reorder_queue.append(old_index)
	_page_reorder_queue.append(new_index)
#endregion


#region Private Methods (Helper)
func _on_sort_children() -> void:
	if !router_info:
		return
	for idx : int in _pages.size():
		var page := _pages[idx]
		if page:
			fit_child_in_rect(page, get_page_rect(idx))

func _page_idx_changed_queued() -> void:
	var old_pages : Array[Page] = _pages.duplicate()
	
	for i : int in range(_page_reorder_queue.size() >> 1):
		var from : int = _page_reorder_queue[i << 1]
		var to : int = _page_reorder_queue[(i << 1) + 1]
		
		var page : Page = old_pages[from]
		if page:
			fit_child_in_rect(page, get_page_rect(to))
		_pages[to] = page
	
	_page_reorder_queue.clear()
	_toggle_load(router_info.get_index(), true)
	_refresh_offscreen_pages()

func _refresh_offscreen_pages() -> void:
	var foo : Callable
	match router_info.page_hide_mode:
		PAGE_HIDE_MODE.NONE:
			foo = _multi_function.bind(_toggle_visible.bind(true), _toggle_processing.bind(true))
		PAGE_HIDE_MODE.HIDE:
			foo = _multi_function.bind(_toggle_visible.bind(false), _toggle_processing.bind(true))
		PAGE_HIDE_MODE.DISABLE:
			foo = _multi_function.bind(_toggle_visible.bind(true), _toggle_processing.bind(false))
		PAGE_HIDE_MODE.HIDE_DISABLE:
			foo = _multi_function.bind(_toggle_visible.bind(false), _toggle_processing.bind(false))
		PAGE_HIDE_MODE.UNLOAD:
			foo = _toggle_load.bind(false)
	
	_bridge_call(0, router_info.get_index() - 1, foo)
	_bridge_call(router_info.get_index() + 1, router_info.size() - 1, foo)
#endregion


#region Private Methods (Helper Multi-Function)
func _bridge_call(st : int, ed : int, foo : Callable) -> void:
	if _pages.is_empty():
		return
	
	for idx : int in range(st, ed + 1):
		foo.call(idx)

func _multi_function(idx : int, foo_1 : Callable, foo_2 : Callable) -> void:
	foo_1.call(idx)
	foo_2.call(idx)
#endregion


#region Private Methods (Rendering)
func _toggle_visible(idx : int, toggle : bool) -> void:
	if !router_info || !router_info.is_vaild_idx(idx) || !_pages[idx]:
		return
	_pages[idx].visible = toggle

func _toggle_processing(idx : int, toggle : bool) -> void:
	if !router_info || !router_info.is_vaild_idx(idx) || !_pages[idx]:
		return
	_pages[idx].process_mode = Node.PROCESS_MODE_INHERIT if toggle else Node.PROCESS_MODE_DISABLED

func _toggle_load(idx : int, toggle : bool) -> void:
	if !router_info || !router_info.is_vaild_idx(idx) || ((_pages[idx] != null) == toggle):
		return
	
	if toggle:
		# Load Page
		var page_scene := router_info.page_infos[idx].page
		if page_scene:
			var page : Page = page_scene.instantiate()
			_pages[idx] = page
			add_child(page)
			fit_child_in_rect(page, get_page_rect(idx))
		return
	
	if router_info.page_load_mode == PAGE_LOAD_MODE.ALL:
		return
	
	# Unload Page
	_pages[idx].queue_free()
	_pages[idx] = null
#endregion


#region Private Methods (Rendering Selector Utility)
func _get_toggle_callable(toggle : bool, hide_mode : PAGE_HIDE_MODE) -> Callable:
	match hide_mode:
		PAGE_HIDE_MODE.NONE:
			return func (idx : int): pass
		PAGE_HIDE_MODE.HIDE:
			return _toggle_visible.bind(toggle)
		PAGE_HIDE_MODE.DISABLE:
			return _toggle_processing.bind(toggle)
		PAGE_HIDE_MODE.HIDE_DISABLE:
			return _multi_function.bind(_toggle_visible.bind(toggle), _toggle_processing.bind(toggle))
		PAGE_HIDE_MODE.UNLOAD:
			return _toggle_load.bind(toggle)
	return Callable()
#endregion


#region Public Methods (Page)
## Gets the indexs of all currently visible page nodes.
func get_visible_pages() -> Array[int]:
	if !router_info:
		return [-1]
	
	var offset := -(position.x * router_info.size()) / size.x
	var flr := floori(offset)
	
	if is_equal_approx(offset, flr):
		return [flr]
	return [flr, flr + 1]

## Gets the page node associated with given page [param idx]. 
## [br][br]
## Returns [code]null[/code] if page is not loaded.
func get_page_node(idx : int) -> Page:
	if !router_info || !router_info.is_vaild_idx(idx) || !_pages[idx]:
		return null
	return _pages[idx]
#endregion


#region Public Methods (Animation)
## Adds the pages needed before animation.
## [br][br]
## Also see: [enum RouterSlideInfo.PAGE_HIDE_MODE].
func add_pages(from : int, to : int) -> void:
	if !router_info:
		return
	
	var foo := _get_toggle_callable(true, router_info.page_hide_mode)
	match router_info.page_load_mode:
		PAGE_LOAD_MODE.ON_DEMAND:
			_toggle_load(to, true)
			foo.call(to)
		PAGE_LOAD_MODE.ON_DEMAND_BRIDGE:
			# Swap if from > to
			if from > to:
				from = from ^ to
				to = from ^ to
				from = from ^ to
			
			_bridge_call(from, to, _toggle_load.bind(true))
			_bridge_call(from, to, foo)
		PAGE_LOAD_MODE.ALL:
			pass
## Removes the pages needed after animation.
## [br][br]
## Also see: [enum RouterSlideInfo.PAGE_HIDE_MODE].
func remove_pages(from : int, to : int) -> void:
	if !router_info:
		return
	
	var foo := _get_toggle_callable(false, router_info.page_hide_mode)
	match router_info.page_load_mode:
		PAGE_LOAD_MODE.ON_DEMAND:
			foo.call(from)
		PAGE_LOAD_MODE.ON_DEMAND_BRIDGE:
			# Swap if from > to
			if from > to:
				from = from ^ to
				to = from ^ to
				from = (from ^ to) + 1
			else:
				to -= 1
			
			_bridge_call(from, to, foo)
		PAGE_LOAD_MODE.ALL:
			pass
## Removes and adds only the pages needed, without animation.
func force_pages(from : int, to : int) -> void:
	if !router_info:
		return
	
	if router_info.page_load_mode != PAGE_LOAD_MODE.ALL:
		_get_toggle_callable(false, router_info.page_hide_mode).call(from)
		_toggle_load(to, true)
	_get_toggle_callable(true, router_info.page_hide_mode).call(to)

## Refreshes all pages. If a page isn't loaded, it does not reload it.
## Otherwise, unloads and reloads in.
func refresh_pages() -> void:
	for i : int in range(_pages.size()):
		refresh_page(i)
## Refreshes the given page. If the page isn't loaded, does nothing.
## Otherwise, unloads and reloads in.
func refresh_page(page_idx : int) -> void:
	if get_page_node(page_idx) == null:
		return
	_toggle_load(page_idx, false)
	_toggle_load(page_idx, true)
#endregion


#region Public Methods (Helper)
## Returns if the given [param idx] is vaild.
## [br][br]
## Also see [member page_infos].
func is_vaild_idx(idx : int) -> bool:
	return router_info && router_info.is_vaild_idx(idx)

## Returns the [Rect2] of a given page.
func get_page_rect(idx : int) -> Rect2:
	if !router_info:
		return Rect2()
	
	var page_width := size.x / router_info.size()
	return Rect2(
		Vector2(idx * page_width, 0),
		Vector2(page_width, size.y)
	)
#endregion
