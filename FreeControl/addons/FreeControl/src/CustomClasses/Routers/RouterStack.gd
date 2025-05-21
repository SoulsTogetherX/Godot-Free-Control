@tool
class_name RouterStack extends PanelContainer



## Built-in Animation types from [enum SwapContainer.ANIMATION_TYPE].
const ANIMATION_TYPE = SwapContainer.ANIMATION_TYPE

## A signal that is emited to transfer events from pages to outside this router.
signal event_action(event : String, args : Variant)

## Emited when animation begins.
## [br][br]
## Also see: [method swap].
signal start_animation
## Emited when animation ends.
## [br][br]
## Also see: [method swap].
signal end_animation


## The file path to a [PackedScene] with a root [Page] node. If The path is not vaild or empty,
## this [RouterStack] will not start with any page.
@export_file("*.tscn") var starting_page : String:
	set(val):
		if val != starting_page:
			starting_page = val
			if Engine.is_editor_hint():
				_clear_all_pages()
				if ResourceLoader.exists(starting_page) && starting_page.get_extension() == "tscn":
					route(starting_page, ANIMATION_TYPE.NONE, ANIMATION_TYPE.NONE)
## Max router stack size.
@export_range(0, 1000, 1, "or_greater") var max_stack : int = 50:
	set(val):
		val = max(val, 1)
		if max_stack != val:
			max_stack = val



@export_group("Animation")
## If [code]true[/code], [Control] nodes will start outside of the camera before animating in
@export var from_outside_screen : bool:
	set(val):
		if val != from_outside_screen:
			from_outside_screen = val
			_stack.from_outside_screen = val
## [Control] nodes start outside of the [SwapContainer] [Rect2] border when an animation plays.
## This offset adds an additional distance, outwards, in which the node will start at.
## [br][br]
## Also see: [method Control.get_rect].
@export var offset : float:
	set(val):
		if val != offset:
			offset = val
			_stack.offset = val

@export_group("Easing")
## The [enum Tween.EaseType] of the entering animation of [Control] nodes.
@export var ease_enter : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if val != ease_enter:
			ease_enter = val
			_stack.ease_enter = val
## The [enum Tween.EaseType] of the exiting animation of [Control] nodes.
@export var ease_exit : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if val != ease_exit:
			ease_exit = val
			_stack.ease_exit = val

@export_group("Transition")
## The [enum Tween.TransitionType] of the entering animation of [Control] nodes.
@export var transition_enter : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC:
	set(val):
		if val != transition_enter:
			transition_enter = val
			_stack.transition_enter = val
## The [enum Tween.TransitionType] of the exiting animation of [Control] nodes.
@export var transition_exit : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC:
	set(val):
		if val != transition_exit:
			transition_exit = val
			_stack.transition_exit = val

@export_group("Duration")
## The duration of the entering animation of [Control] nodes.
@export var duration_enter : float = 0.35:
	set(val):
		if val != duration_enter:
			duration_enter = val
			_stack.duration_enter = val
## The duration of the exiting animation of [Control] nodes.
@export var duration_exit : float = 0.35:
	set(val):
		if val != duration_exit:
			duration_exit = val
			_stack.duration_exit = val


var _page_stack : Array[PageInfo] = []
var _params : Dictionary = {}
var _stack : SwapContainer



## Emits the [Signal Page.entered] signal on the current [Page] when called. If this router is
## a descendant of another [Page], attach the assessor's [Page]'s  [Signal Page.entered] signal
## to this method for best results.
func emit_entered() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.entered.emit()
## Emits the [Signal Page.entering] signal on the current [Page] when called. If this router is
## a descendant of another [Page], attach the assessor's [Page]'s  [Signal Page.entering] signal
## to this method for best results.
func emit_entering() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.entering.emit()
## Emits the [Signal Page.exited] signal on the current [Page] when called. If this router is
## a descendant of another [Page], attach the assessor's [Page]'s  [Signal Page.exited] signal
## to this method for best results.
func emit_exited() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.exited.emit()
## Emits the [Signal Page.exiting] signal on the current [Page] when called. If this router is
## a descendant of another [Page], attach the assessor's [Page]'s  [Signal Page.exiting] signal
## to this method for best results.
func emit_exiting() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.exiting.emit()



## Routes to a [Page] with the given filepath. Adds the page to the router stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func route(
	page_path : String,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	var packed : PackedScene = await _ResourceLoader.new(get_tree().process_frame, page_path).finished
	if packed == null:
		push_error("An error occured while attempting to load file at filepath '", page_path, "'")
		return null
	
	return await route_packed(
		packed,
		enter_animation,
		exit_animation,
		params,
		args
	)
## Routes to a [Page] with the given PackedScene. Adds the page to the router stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func route_packed(
	page_scene : PackedScene,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	if page_scene == null:
		push_error("page_scene cannot be 'null'")
		return null
	
	return await route_node(
		page_scene.instantiate(),
		enter_animation,
		exit_animation,
		params,
		args
	)
## Routes to the given [Page] node. Adds the page to the router stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func route_node(
	page : Page,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	if !page:
		push_error("page cannot be 'null'")
		return null
	_params = params
	
	var enter_page : PageInfo = PageInfo.new(
		page,
		enter_animation,
		exit_animation,
		args.get("auto_clean", true)
	)
	
	_stack.set_modifers(args)
	_append_to_page_queue(enter_page)
	
	await _handle_swap(
		enter_page.get_page(),
		enter_animation,
		exit_animation
	)
	
	return page


## Routes to a [Page] with the given filepath. Clears the current reouter stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func navigate(
	page_path : String,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	var packed : PackedScene= await _ResourceLoader.new(get_tree().process_frame, page_path).finished
	if packed == null:
		push_error("An error occured while attempting to load file at filepath '", page_path, "'")
		return null
	
	return await navigate_packed(
		packed,
		enter_animation,
		exit_animation,
		params,
		args
	)
## Routes to a [Page] with the given PackedScene. Clears the current reouter stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func navigate_packed(
	page_scene : PackedScene,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	if page_scene == null:
		push_error("page_scene cannot be 'null'")
		return null
	
	return await navigate_node(
		page_scene.instantiate(),
		enter_animation,
		exit_animation,
		params,
		args
	)
## Routes to the given [Page] node. Clears the current reouter stack.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func navigate_node(
	page : Page,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	if !page:
		push_error("page cannot be 'null'")
		return null
	_params = params
	
	var enter_info : PageInfo = PageInfo.new(
		page,
		enter_animation,
		exit_animation,
		args.get("auto_clean", true)
	)
	
	_stack.set_modifers(args)
	_append_to_page_queue(enter_info)
	
	await _handle_swap(
		enter_info.get_page(),
		enter_animation,
		exit_animation
	)
	_clear_stack()
	
	return page


## Pops the current [Page] off the router stack and routes to the previous [Page] node.
## If the router stack is empty, then nothing will happen.
## [param params] will be transfered to the routed [Page].
## [param args] control how the animation occures.
## [br][br]
## Also see: [method SwapContainer.set_modifers].
func back(
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> void:
	if is_empty(): return
	_params = params
	_stack.set_modifers(args)
	
	var exit_page : PageInfo = _page_stack.pop_back()
	var enter_page : PageInfo = _page_stack.back()
	
	enter_page.get_page().event_action.connect(event_action.emit)
	
	if enter_animation == ANIMATION_TYPE.DEFAULT:
		enter_animation = _reverse_animate(exit_page.get_exit_animation())
	if exit_animation == ANIMATION_TYPE.DEFAULT:
		exit_animation = _reverse_animate(exit_page.get_enter_animation())
	
	await _handle_swap(
		enter_page.get_page(),
		enter_animation,
		exit_animation,
		false
	)


## Gets the last passed in param.
func get_params() -> Dictionary:
	return _params
## Gets the current size of the router stack.
func stack_size() -> int:
	return _page_stack.size()
## Returns [code]true[/code] is the stack is empty (has a size of <= 1).
func is_empty() -> bool:
	return _page_stack.size() <= 1
## Returns the [PageInfo] of the last appened [Page] on the router stack.
## If there is nothing on the router stack, then return [code]null[/code].
func get_current_page() -> PageInfo:
	return null if _page_stack.is_empty() else _page_stack.back()


func _handle_swap(
	enter_page : Page,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	front : bool = true
) -> void:
	var exit_page : Page = _stack.get_current()
	
	if enter_page:
		enter_page.entering.emit()
	if exit_page:
		exit_page.exiting.emit()
	
	await _stack.swap(
		enter_page,
		enter_animation,
		exit_animation,
		front
	)
	
	if enter_page:
		enter_page.entered.emit()
	if exit_page:
		exit_page.exited.emit()
	
	

func _append_to_page_queue(page_node: PageInfo) -> void:
	if !_page_stack.is_empty():
		_page_stack.back().get_page().event_action.disconnect(event_action.emit)
	if _page_stack.size() > max_stack:
		_page_stack.pop_front()
	_page_stack.append(page_node)
	
	var page := page_node.get_page()
	if !page.event_action.is_connected(event_action.emit):
		page.event_action.connect(event_action.emit)

func _reverse_animate(animation : ANIMATION_TYPE) -> ANIMATION_TYPE:
	match animation:
		ANIMATION_TYPE.NONE:
			return ANIMATION_TYPE.NONE
		ANIMATION_TYPE.LEFT:
			return ANIMATION_TYPE.RIGHT
		ANIMATION_TYPE.RIGHT:
			return ANIMATION_TYPE.LEFT
		ANIMATION_TYPE.TOP:
			return ANIMATION_TYPE.BOTTOM
		ANIMATION_TYPE.BOTTOM:
			return ANIMATION_TYPE.TOP
	return ANIMATION_TYPE.NONE


func _clear_stack() -> void:
	_page_stack = [_page_stack.back()]
func _clear_all_pages() -> void:
	_page_stack = []



func _init() -> void:
	_stack = SwapContainer.new()
	add_child(_stack)
	_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	_stack.start_animation.connect(start_animation.emit)
	_stack.end_animation.connect(end_animation.emit)
	
	_stack.from_outside_screen = from_outside_screen
	_stack.offset = offset
	
	_stack.ease_enter = ease_enter
	_stack.ease_exit = ease_exit
	
	_stack.transition_enter = transition_enter
	_stack.transition_exit = transition_exit
	
	_stack.duration_enter = duration_enter
	_stack.duration_exit = duration_exit
	
	if ResourceLoader.exists(starting_page) && starting_page.get_extension() == "tscn":
		route(starting_page, ANIMATION_TYPE.NONE, ANIMATION_TYPE.NONE)



class _ResourceLoader:
	signal finished(scene : PackedScene)
	
	var _resource_name : String
	
	func _init(check_signal : Signal, path : StringName) -> void:
		_resource_name = path
		
		if !ResourceLoader.exists(_resource_name):
			push_error("Error - Invaild Resource Loaded")
			check_signal.connect(_delay_failsave, CONNECT_ONE_SHOT)
			return
		
		check_signal.connect(_on_signal)
		ResourceLoader.load_threaded_request(
			_resource_name,
			"PackedScene"
		)
	
	func _on_signal() -> void:
		match ResourceLoader.load_threaded_get_status(_resource_name):
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
				finished.emit(null)
			ResourceLoader.THREAD_LOAD_LOADED:
				finished.emit(ResourceLoader.load_threaded_get(_resource_name))
	func _delay_failsave() -> void:
		finished.emit(null)
