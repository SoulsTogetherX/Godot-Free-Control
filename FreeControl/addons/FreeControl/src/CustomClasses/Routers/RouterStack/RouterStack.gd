# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name RouterStack extends PanelContainer
## Handles a [Control] stack, between [Page] nodes, using [SwapContainer].

#region Signals
## Emits when the current [Page] requests an event.
signal event_action(event : String, args : Variant)

## Emits at the start of a transition.
signal start_transition
## Emits at the end of a transition.
signal end_transition
#endregion


#region Enums
## The Animation type to transition with.
const ANIMATION_TYPE = SwapContainer.ANIMATION_TYPE
#endregion


#region External Variables
## The filepath to the [Page] node this to load on ready. If this path is invaild,
## or not to a [PackedScene] with a [Page] node root, nothing will be loaded on ready.
@export_file("*.tscn") var starting_page : String:
	set(val):
		if val != starting_page:
			starting_page = val
			if Engine.is_editor_hint() && is_node_ready():
				_clear_all_pages()
				if ResourceLoader.exists(starting_page) && starting_page.get_extension() == "tscn":
					route(starting_page, ANIMATION_TYPE.NONE, ANIMATION_TYPE.NONE)
## The max size of the stack. If the stack is too big, it will clear the oldest on
## the stack first.
@export_range(0, 1000, 1, "or_greater") var max_stack : int = 50:
	set(val):
		val = max(val, 1)
		if max_stack != val:
			max_stack = val


@export_group("Animation")
## Starts animation with the [Control] node outside of the visisble screen.
@export var from_outside_screen : bool:
	set(val):
		if val != from_outside_screen:
			from_outside_screen = val
			_stack.from_outside_screen = val
## Starts animation an offset of this amount of pixels (away from the center), start
## at the position the [Control] originally would be placed at.
@export_range(0, 500, 1, "or_less", "or_greater", "suffix:px") var offset : float:
	set(val):
		if val != offset:
			offset = val
			_stack.offset = val

@export_group("Easing")
## The [enum Tween.EaseType] that will be used as the new [Control] transitions in.
@export var ease_enter : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if val != ease_enter:
			ease_enter = val
			_stack.ease_enter = val
## The [enum Tween.EaseType] that will be used as the current [Control] transitions out.
@export var ease_exit : Tween.EaseType = Tween.EaseType.EASE_IN_OUT:
	set(val):
		if val != ease_exit:
			ease_exit = val
			_stack.ease_exit = val

@export_group("Transition")
## The [enum Tween.TransitionType] that will be used as the new [Control] transitions in.
@export var transition_enter : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC:
	set(val):
		if val != transition_enter:
			transition_enter = val
			_stack.transition_enter = val
## The [enum Tween.TransitionType] that will be used as the current [Control] transitions out.
@export var transition_exit : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC:
	set(val):
		if val != transition_exit:
			transition_exit = val
			_stack.transition_exit = val

@export_group("Duration")
## The duration of the animation used as the new [Control] transitions in.
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var duration_enter : float = 0.35:
	set(val):
		if val != duration_enter:
			duration_enter = val
			_stack.duration_enter = val
## The duration of the animation used as the current [Control] transitions out.
@export_range(0, 5, 0.001, "or_greater", "suffix:sec") var duration_exit : float = 0.35:
	set(val):
		if val != duration_exit:
			duration_exit = val
			_stack.duration_exit = val
#endregion


#region Private Variables
var _page_stack : Array[PageStackInfo] = []
var _params : Dictionary = {}
var _stack : SwapContainer
#endregion


#region Private Virtual Methods
func _init() -> void:
	if _stack && is_instance_valid(_stack):
		_stack.queue_free()
	_stack = SwapContainer.new()
	add_child(_stack)
	_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	_stack.start_transition.connect(start_transition.emit)
	_stack.end_transition.connect(end_transition.emit)
	
	_stack.from_outside_screen = from_outside_screen
	_stack.offset = offset
	
	_stack.ease_enter = ease_enter
	_stack.ease_exit = ease_exit
	
	_stack.transition_enter = transition_enter
	_stack.transition_exit = transition_exit
	
	_stack.duration_enter = duration_enter
	_stack.duration_exit = duration_exit
#endregion


#region Private Methods
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
	
	await _stack.swap_control(
		enter_page,
		enter_animation,
		exit_animation,
		front
	)
	
	if enter_page:
		enter_page.entered.emit()
	if exit_page:
		exit_page.exited.emit()

func _append_to_page_queue(page_node: PageStackInfo) -> void:
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
#endregion


#region Public Methods
## Emits the [Signal Page.entered] signal on the current [Page] displayed.
## [br][br]
## If this Router is a decedent of another [Page], connect that [Page]'s
## [Signal Page.entered] with this method.
func emit_entered() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.entered.emit()
## Emits the [Signal Page.entering] signal on the current [Page] displayed.
## [br][br]
## If this Router is a decedent of another [Page], connect that [Page]'s
## [Signal Page.entering] with this method.
func emit_entering() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.entering.emit()
## Emits the [Signal Page.exited] signal on the current [Page] displayed.
## [br][br]
## If this Router is a decedent of another [Page], connect that [Page]'s
## [Signal Page.exited] with this method.
func emit_exited() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.exited.emit()
## Emits the [Signal Page.exiting] signal on the current [Page] displayed.
## [br][br]
## If this Router is a decedent of another [Page], connect that [Page]'s
## [Signal Page.exiting] with this method.
func emit_exiting() -> void:
	var curr_page : Page = null if _page_stack.is_empty() else _page_stack[0].get_page()
	if curr_page:
		curr_page.exiting.emit()


## Routes to a [Page] node given by a file path to a [PackedScene].
func route(
	page_path : String,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	var packed : PackedScene = await LocalResourceLoader.new(get_tree().process_frame, page_path).finished
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
## Routes to a [Page] node given by a [PackedScene].
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
## Routes to a given [Page] node.
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
	
	var enter_page := PageStackInfo.create(
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


## Routes to a [Page] node given by a file path to a [PackedScene]. Clears stack.
func navigate(
	page_path : String,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> Page:
	var packed : PackedScene = await LocalResourceLoader.new(get_tree().process_frame, page_path).finished
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
## Routes to a [Page] node given by a [PackedScene]. Clears stack.
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
## Routes to a given [Page] node. Clears stack.
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
	
	var enter_info := PageStackInfo.create(
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


## Routes to the previous [Control] on the stack. If the stack is empty, nothing will happen.
func back(
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	params : Dictionary = {},
	args : Dictionary = {}
) -> void:
	if is_empty(): return
	_params = params
	_stack.set_modifers(args)
	
	var exit_page : PageStackInfo = _page_stack.pop_back()
	var enter_page : PageStackInfo = _page_stack.back()
	
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


## Gets the parameters of the last route. 
func get_params() -> Dictionary:
	return _params
## Gets the current stack size.
func stack_size() -> int:
	return _page_stack.size()
## Returns if the stack is empty.
func is_empty() -> bool:
	return _page_stack.size() <= 1
## Returns the current [Page] on display.
func get_current_page() -> PageStackInfo:
	return null if _page_stack.is_empty() else _page_stack.back()
#endregion


#region Subclasses
class LocalResourceLoader:
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
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
