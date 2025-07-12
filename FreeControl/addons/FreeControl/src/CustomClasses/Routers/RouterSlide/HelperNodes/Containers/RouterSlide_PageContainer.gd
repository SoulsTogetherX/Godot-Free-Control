# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## The [Container] that holds and maintains all the pages for [RouterSlide].

#region Signal
## Emits when the current [Page] requests an event.
signal event_action(event : String, args : Variant)

## Emits at the start of a transition.
signal start_transition
## Emits at the end of a transition.
signal end_transition
#endregion


#region Enums
## An Enum related to how this node will lazy-initiated [Page]s.
const PAGE_HIDE_MODE = RouterSlide.PAGE_HIDE_MODE

## An Enum related to how this node will hide already initiated [Page]s that
## are outside of visible space.
const PAGE_LOAD_MODE = RouterSlide.PAGE_LOAD_MODE
#endregion


#region External Variables
## Controls how this node will lazy-initiated [Page]s.
@export var load_mode : PAGE_LOAD_MODE = PAGE_LOAD_MODE.ON_DEMAND:
	set = set_load_mode
## Controls how this node will hide already initiated [Page]s that are
## outside of visible space.
@export var hide_mode : PAGE_HIDE_MODE:
	set = set_hide_mode


## Length of time for this [Node] to swap [Page]s.
@export var page_speed : float = 0.4:
	set(val):
		if page_speed != val:
			page_speed = val
## The [enum Tween.EaseType] for [Page] animation.
@export var page_ease : Tween.EaseType = Tween.EASE_IN_OUT:
	set(val):
		if page_ease != val:
			page_ease = val
## The [enum Tween.TransitionType] for [Page] animation.
@export var page_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		if page_trans != val:
			page_trans = val
#endregion


#region Private Variables
var _index : int = -1

var _pages : Array[Page]
var _pages_info : Array[RouterTabInfo]
var _pages_lambdas : Array[Callable]

var _shift_node : Container
var _animation_tween : Tween

var _ignore_queue : int = 0
#endregion


#region Private Virtual Methods
func _init() -> void:
	_shift_node = Container.new()
	add_child(_shift_node)

func _set_page_info(new_info : Array[RouterTabInfo]) -> void:
	_pages_lambdas.resize(new_info.size())
	for idx : int in new_info.size():
		var info := new_info[idx]
		var lambda := _pages_lambdas[idx]
		
		if lambda && info.page_changed.is_connected(lambda):
			info.page_changed.disconnect(lambda)
	
	_pages_lambdas.resize(_pages_info.size())
	for idx : int in _pages_info.size():
		var info := _pages_info[idx]
		var lambda : Callable = _refresh_page.bind(idx)
		
		_pages_lambdas[idx] = lambda
		info.page_changed.connect(lambda)
	_pages_info = new_info

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_pages()
#endregion


#region Helper Private Methods
func _sort_pages() -> void:
	_position_to(_index)
	
	for idx : int in _pages.size():
		var page : Page = _pages[idx]
		if !page:
			continue
		
		_shift_node.fit_child_in_rect(
			page,
			Rect2(
				Vector2(size.x * idx, 0),
				size
			)
		)
func _clear_pages() -> void:
	for page : Page in _pages:
		if !page:
			continue
		page.queue_free()
	_pages = []


func _animate_to(idx : int) -> Signal:
	_animation_tween = create_tween()
	_animation_tween.set_ease(page_ease)
	_animation_tween.set_trans(page_trans)
	_animation_tween.tween_property(
		_shift_node,
		"position:x",
		-size.x * idx,
		page_speed
	)
	
	return _animation_tween.finished
func _position_to(idx : int) -> void:
	fit_child_in_rect(
		_shift_node,
		Rect2(
			Vector2(-size.x * idx, 0),
			Vector2(size.x * _pages_info.size(), size.y)
		)
	)


func _entered_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].entered.emit()
func _entering_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	var page := _pages[idx]
	if !page.event_action.is_connected(event_action.emit):
		page.event_action.connect(event_action.emit)
	page.entering.emit()
func _exited_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].exited.emit()
func _exiting_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	var page := _pages[idx]
	page.exiting.emit()
	if page.event_action.is_connected(event_action.emit):
		page.event_action.disconnect(event_action.emit)


func _helper_call_single(st : int, ed : int, foo : Callable, ignore_current : bool) -> void:
	if _index != st || !ignore_current:
		foo.call(st)
	if _index != ed || !ignore_current:
		foo.call(ed)
func _helper_call_bridge(st : int, ed : int, foo : Callable, ignore_current : bool) -> void:
	for idx : int in range(st, ed + 1):
		if ignore_current && _index == idx:
			continue
		foo.call(idx)
#endregion


#region Add/Remove Private Methods
func _show_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].visible = true
func _hide_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].visible = false

func _enable_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].process_mode = Node.PROCESS_MODE_INHERIT
func _disable_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].process_mode = Node.PROCESS_MODE_DISABLED

func _show_enable_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	var page := _pages[idx]
	page.visible = true
	page.process_mode = Node.PROCESS_MODE_INHERIT
func _hide_disable_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	var page := _pages[idx]
	page.visible = false
	page.process_mode = Node.PROCESS_MODE_DISABLED


func _get_add_callable() -> Callable:
	match hide_mode:
		PAGE_HIDE_MODE.NONE, PAGE_HIDE_MODE.UNLOAD:
			pass
		PAGE_HIDE_MODE.HIDE:
			return _show_page
		PAGE_HIDE_MODE.DISABLE:
			return _enable_page
		PAGE_HIDE_MODE.HIDE_DISABLE:
			return _show_enable_page
	return Callable()

func _get_remove_callable() -> Callable:
	match hide_mode:
		PAGE_HIDE_MODE.UNLOAD, PAGE_HIDE_MODE.NONE:
			pass
		PAGE_HIDE_MODE.HIDE:
			return _hide_page
		PAGE_HIDE_MODE.DISABLE:
			return _disable_page
		PAGE_HIDE_MODE.HIDE_DISABLE:
			return _hide_disable_page
	return Callable()



func _add_page_multiple(st : int, ed : int, ignore_current : bool = false) -> void:
	var foo : Callable = _get_add_callable()
	if foo.is_null():
		return
	
	for idx : int in range(st, ed + 1):
		if ignore_current && _index == idx:
			continue
		foo.call(idx)
func _remove_page_multiple(st : int, ed : int, ignore_current : bool = false) -> void:
	var foo : Callable
	if Engine.is_editor_hint() && load_mode != PAGE_LOAD_MODE.ALL:
		foo = _unload_page
	else:
		if load_mode == PAGE_LOAD_MODE.ALL && hide_mode == PAGE_HIDE_MODE.UNLOAD:
			return
		
		foo = _get_remove_callable()
		if foo.is_null():
			return
	
	for idx : int in range(st, ed + 1):
		if ignore_current && _index == idx:
			continue
		foo.call(idx)
#endregion


#region Load/Unload Private Methods
func _refresh_page(idx : int) -> void:
	if idx in get_visible_pages():
		_unload_page(idx)
		_load_page(idx)
		
		if _index != idx:
			return
		
		var page : Page = _pages[idx]
		if page:
			page.entering.emit()
			page.entering.emit()

func _load_page(idx : int) -> void:
	if !is_index_vaild(idx) || _pages[idx] != null || !_pages_info[idx].page:
		return
	
	var page : Page = _pages_info[idx].page.instantiate()
	page.clip_contents = true
	
	_pages[idx] = page
	_shift_node.add_child(page)
	
	_shift_node.fit_child_in_rect(
		page,
		Rect2(
			Vector2(size.x * idx, 0),
			size
		)
	)
func _unload_page(idx : int) -> void:
	if !page_is_loaded(idx):
		return
	
	_pages[idx].queue_free()
	_pages[idx] = null


func _load_page_multiple(idx : int, st : int, ed : int, ignore_current : bool = false) -> void:
	match load_mode:
		PAGE_LOAD_MODE.ON_DEMAND:
			_helper_call_single(st, ed, _load_page, ignore_current)
		PAGE_LOAD_MODE.ON_DEMAND_BRIDGE:
			_helper_call_bridge(st, ed, _load_page, ignore_current)
		PAGE_LOAD_MODE.ALL:
			return
func _unload_page_multiple(old_idx : int, st : int, ed : int, ignore_current : bool = false) -> void:
	if load_mode == PAGE_LOAD_MODE.ALL:
		return
	
	if Engine.is_editor_hint() || hide_mode == PAGE_HIDE_MODE.UNLOAD:
		_helper_call_bridge(st, ed, _unload_page, ignore_current)
#endregion


#region Emit Methods
func emit_entered() -> void:
	if !page_is_loaded(_index):
		return
	_pages[_index].entered.emit()
func emit_entering() -> void:
	if !page_is_loaded(_index):
		return
	_pages[_index].entering.emit()
func emit_exited() -> void:
	if !page_is_loaded(_index):
		return
	_pages[_index].exited.emit()
func emit_exiting() -> void:
	if !page_is_loaded(_index):
		return
	_pages[_index].exiting.emit()
#endregion


#region Public Methods
## Initializes the page with the given array of [RouterTabInfo]s, and
## starting at the given [param start_idx].
func inital_pages(pages_info : Array[RouterTabInfo], start_idx : int) -> void:
	_set_page_info(pages_info)
	
	start_idx = clampi(start_idx, 0, _pages_info.size())
	_index = -1
	
	_clear_pages()
	
	_pages.resize(_pages_info.size())
	_pages.fill(null)
	
	if is_node_ready():
		goto_index(start_idx, false)

## Sets the current [Page] to the given vaild index.
## [br][br]
## The [param idx] is clamped to a vaild index. If [code]animate[/code] is true
## the node will animated the transition between pages. 
func goto_index(idx : int, animate : bool) -> void:
	idx = clampi(idx, 0, _pages_info.size())
	if _index == idx:
		return
	
	start_transition.emit()
	
	if _animation_tween && _animation_tween.is_running():
		_ignore_queue += 1
		_animation_tween.finished.emit()
		_animation_tween.kill()
	
	var max : int
	var min : int
	var visible_pages := get_visible_pages()
	
	if _index < idx:
		max = max(idx, visible_pages.back())
		min = visible_pages.front()
	else:
		max = visible_pages.back()
		min = min(idx, visible_pages.front())
	
	_load_page_multiple(idx, min, max)
	_add_page_multiple(min, max)
	
	_exited_page(_index)
	_entering_page(idx)
	
	if animate:
		await _animate_to(idx)
	else:
		_position_to(idx)
	
	_exited_page(_index)
	_entered_page(idx)
	
	_index = idx
	
	_unload_page_multiple(idx, min, max, _ignore_queue == 0)
	_remove_page_multiple(min, max, _ignore_queue == 0)
	_ignore_queue = max(0, _ignore_queue - 1)
	
	end_transition.emit()


## Gets the current page node.
## [br][br]
## [b]Warning[/b]: This is a required internal node, removing and freeing it
## may cause a crash.
func get_page_node() -> Page:
	if !is_index_vaild(_index):
		return null
	return _pages[_index]
## Gets the page node at the corresponding index.
## [br][br]
## [b]Warning[/b]: This is a required internal node, removing and freeing it
## may cause a crash.
func get_page_node_by_index(idx : int) -> Page:
	if !is_index_vaild(idx):
		return null
	return _pages[idx]
## Gets the index of the current page node.
func get_page_index() -> int:
	return _index
## Returns the indexes of all currently visible pages.
## [br][br]
## [b]NOTE[/b]: Multiple pages can be visible during animations.
func get_visible_pages() -> Array[int]:
	var offset := -_shift_node.position.x / size.x
	var flr := floori(offset)
	
	if flr == offset:
		return [flr]
	return [flr, flr + 1]

## Returns if the given index is vaild.
func is_index_vaild(idx : int) -> bool:
	return 0 <= idx && idx < _pages.size()

## Returns if the page, associated with the given node, is loaded.
func page_is_loaded(idx : int) -> bool:
	return is_index_vaild(idx) && _pages[idx] != null
## Returns if the page, associated with the given node, is visible and loaded.
func page_is_visible(idx : int) -> bool:
	return page_is_loaded(idx) && _pages[idx].is_visible_in_tree()


## The setter of [memeber load_mode]. 
func set_load_mode(new : PAGE_LOAD_MODE) -> void:
	load_mode = new
	
	if new == PAGE_LOAD_MODE.ALL:
		_helper_call_bridge(0, _pages_info.size() - 1, _load_page, false)
	elif Engine.is_editor_hint():
		_helper_call_bridge(0, _pages_info.size() - 1, _unload_page, true)
## The setter of [memeber hide_mode]. 
func set_hide_mode(new : PAGE_HIDE_MODE) -> void:
	hide_mode = new
	if hide_mode == PAGE_HIDE_MODE.UNLOAD:
		return
	
	match new:
		PAGE_HIDE_MODE.NONE:
			_helper_call_bridge(0, _pages.size() - 1, _show_enable_page, true)
		PAGE_HIDE_MODE.HIDE:
			var foo = func(idx : int):
				if _pages[idx] != null:
					_hide_page(idx)
					_enable_page(idx)
			
			_helper_call_bridge(0, _pages.size() - 1, _show_enable_page, true)
			_show_enable_page(_index)
		PAGE_HIDE_MODE.DISABLE:
			var foo = func(idx : int):
				if _pages[idx] != null:
					_show_page(idx)
					_disable_page(idx)
			
			_helper_call_bridge(0, _pages.size() - 1, _show_enable_page, true)
			_show_enable_page(_index)
		PAGE_HIDE_MODE.HIDE_DISABLE:
			_helper_call_bridge(0, _pages.size() - 1, _show_enable_page, true)
			_show_enable_page(_index)
		PAGE_HIDE_MODE.UNLOAD:
			if load_mode == PAGE_LOAD_MODE.ALL:
				return
			
			_helper_call_bridge(0, _pages.size() - 1, _unload_page, true)
			_show_enable_page(_index)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
