# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name SwapContainer extends Container
## A [Container] node that provides transitions between different [Control] nodes.

#region Signals
## Emits at the start of a transition.
signal start_transition
## Emits at the end of a transition.
signal end_transition
#endregion


#region Enums
## The Animation type to transition with.
enum ANIMATION_TYPE {
	DEFAULT, ## The same as [constant LEFT].
	NONE, ## No Transition
	LEFT, ## Either moves towards or away the left
	RIGHT, ## Either moves towards or away the right
	TOP, ## Either moves towards or away the top
	BOTTOM ## Either moves towards or away the bottom
}
#endregion


#region External Variables
@export_group("Animation")
## Starts animation with the [Control] node outside of the visisble screen.
@export var from_outside_screen : bool
## Starts animation an offset of this amount of pixels (away from the center), start
## at the position the [Control] originally would be placed at.
@export var offset : float

@export_group("Easing")
## The [enum Tween.EaseType] that will be used as the new [Control] transitions in.
@export var ease_enter : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
## The [enum Tween.EaseType] that will be used as the current [Control] transitions out.
@export var ease_exit : Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_group("Transition")
## The [enum Tween.TransitionType] that will be used as the new [Control] transitions in.
@export var transition_enter : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
## The [enum Tween.TransitionType] that will be used as the current [Control] transitions out.
@export var transition_exit : Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC

@export_group("Duration")
## The duration of the animation used as the new [Control] transitions in.
@export var duration_enter : float = 0.35
## The duration of the animation used as the current [Control] transitions out.
@export var duration_exit : float = 0.35
#endregion


#region Private Variables
var _enter_tween : Tween = null
var _exit_tween : Tween = null
var _current_node : Control
#endregion


#region Private Methods
func _parent_control(node: Control, front : bool) -> void:
	if !node: return
	if !node.get_parent():
		add_child(node)
	
	if is_inside_tree():
		node.hide()
		get_tree().process_frame.connect(node.show, CONNECT_ONE_SHOT)
	
	if front:
		node.move_to_front()
	else:
		move_child(node, 0)
	
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func _unparent_control(node: Control) -> void:
	remove_child(node)

func _perform_animations(
	enter_node: Control,
	exit_node: Control,
	enter_animation: ANIMATION_TYPE,
	exit_animation: ANIMATION_TYPE
) -> void:
	if enter_animation == ANIMATION_TYPE.NONE && exit_animation == ANIMATION_TYPE.NONE:
		if enter_node:
			enter_node.position = Vector2.ZERO
		return
	_tween_settup()
	
	if enter_node:
		_handle_enter_animation(
			enter_node,
			_enter_tween,
			enter_animation
		)
	else:
		_enter_tween.finished.emit()
		_enter_tween.kill()
		_enter_tween = null
	if exit_node:
		_handle_exit_animation(
			exit_node,
			_exit_tween,
			exit_animation,
		)
	else:
		_exit_tween.finished.emit()
		_exit_tween.kill()
		_exit_tween = null
	
	await _await_animations()
func _handle_enter_animation(
	node: Control,
	animation_tween : Tween,
	animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
) -> void:
	var border := _get_border()
	
	match animation:
		ANIMATION_TYPE.DEFAULT, ANIMATION_TYPE.LEFT:
			animation_tween.tween_method(
				func (val): node.position.x = val,
				border.position.x,
				0,
				duration_enter
			)
		ANIMATION_TYPE.RIGHT:
			animation_tween.tween_method(
				func (val): node.position.x = val,
				border.size.x - border.position.x,
				0,
				duration_enter
			)
		ANIMATION_TYPE.TOP:
			animation_tween.tween_method(
				func (val): node.position.y = val,
				border.position.y,
				0,
				duration_enter
			)
		ANIMATION_TYPE.BOTTOM:
			animation_tween.tween_method(
				func (val): node.position.y = val,
				border.size.y - border.position.y,
				0,
				duration_enter
			)
		_:
			node.position = Vector2.ZERO
			return
	
	animation_tween.play()
func _handle_exit_animation(
	node: Control,
	animation_tween : Tween,
	animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
) -> void:
	var border : Rect2 = _get_border()
	
	match animation:
		ANIMATION_TYPE.DEFAULT, ANIMATION_TYPE.LEFT:
			animation_tween.tween_method(
				func (val): node.position.x = val,
				0,
				border.size.x - border.position.x,
				duration_enter
			)
		ANIMATION_TYPE.RIGHT:
			animation_tween.tween_method(
				func (val): node.position.x = val,
				0,
				border.position.x,
				duration_enter
			)
		ANIMATION_TYPE.TOP:
			animation_tween.tween_method(
				func (val): node.position.y = val,
				0,
				border.size.y - border.position.y,
				duration_enter
			)
		ANIMATION_TYPE.BOTTOM:
			animation_tween.tween_method(
				func (val): node.position.y = val,
				0,
				border.position.y,
				duration_enter
			)
		_:
			node.position = Vector2.ZERO
			return
	
	animation_tween.play()


func _tween_settup() -> void:
	if _enter_tween && _enter_tween.is_running():
		_enter_tween.finished.emit()
		_enter_tween.kill()
	_enter_tween = create_tween()
	
	_enter_tween.set_ease(ease_enter)
	_enter_tween.set_trans(transition_enter)
	_enter_tween.stop()
	
	if _exit_tween && _exit_tween.is_running():
		_exit_tween.finished.emit()
		_exit_tween.kill()
	_exit_tween = create_tween()
	
	_exit_tween.set_ease(ease_exit)
	_exit_tween.set_trans(transition_exit)
	_exit_tween.stop()
	
func _get_border() -> Rect2:
	var boarder : Rect2
	
	if from_outside_screen:
		boarder.position = -global_position - size
		boarder.size = get_viewport_rect().size - size
	else:
		boarder.position = -size
		boarder.size = Vector2.ZERO
	
	boarder.position -= Vector2(offset, offset)
	return boarder


func _await_animations() -> void:
	@warning_ignore("incompatible_ternary")
	await SignalMerge.new(
		_enter_tween.finished if _enter_tween && _enter_tween.is_running() else null,
		_exit_tween.finished if _exit_tween && _exit_tween.is_running() else null
	).finished
#endregion


#region Public Methods
## Causes the current [Control] node to transition out and [param node]
## to transition in.
func swap_control(
	node : Control,
	enter_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	exit_animation: ANIMATION_TYPE = ANIMATION_TYPE.DEFAULT,
	front : bool = true
) -> Control:
	var _old_node := _current_node
	_parent_control(node, front)
	
	start_transition.emit()
	_current_node = node
	await _perform_animations(
		node,
		_old_node,
		enter_animation,
		exit_animation
	)
	
	if _old_node:
		_unparent_control(_old_node)
	end_transition.emit()
	
	return _old_node
## Sets all export members with a simple  [Dictionary].
func set_modifers(args : Dictionary) -> void:
	if args.has("ease_enter"):
		ease_enter = args.get("ease_enter")
	if args.has("ease_exit"):
		ease_exit = args.get("ease_exit")
	
	if args.has("transition_enter"):
		transition_enter = args.get("transition_enter")
	if args.has("transition_exit"):
		transition_exit = args.get("transition_exit")
	
	if args.has("duration_enter"):
		duration_enter = args.get("duration_enter")
	if args.has("duration_exit"):
		duration_exit = args.get("duration_exit")


## Gets the current [Control] displayed. [code]null[/code] if there is currently no such
## [Control].
func get_current() -> Control:
	return _current_node
#endregion


#region Subclasses
class SignalMerge:
	signal finished
	var _activate : bool = false
	
	func _init(enter, exit) -> void:
		_register(enter)
		_register(exit)
	func _register(arg) -> void:
		if arg is Signal:
			arg.connect(_unleash)
			return
		_unleash()
	func _unleash() -> void:
		if _activate: finished.emit()
		_activate = true
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
