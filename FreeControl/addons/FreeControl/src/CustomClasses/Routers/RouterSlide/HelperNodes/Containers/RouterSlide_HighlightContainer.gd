# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## The [Container] that holds and maintains the highlight for [RouterSlide].

#region Signals
## Emits at the start of a transition.
signal start_transition
## Emits at the end of a transition.
signal end_transition
#endregion


#region External Methods
## The number of tabs the highlight should shrink to accommodate.
@export var tab_number : int:
	set(val):
		if tab_number != val:
			tab_number = val
			_position_highlight()

## Length of time for the highlight to animate.
@export var animation_speed : float = 0.4:
	set(val):
		if animation_speed != val:
			animation_speed = val
## The [enum Tween.EaseType] for highlight animation.
@export var animation_ease : Tween.EaseType = Tween.EASE_OUT:
	set(val):
		if animation_ease != val:
			animation_ease = val
## The [enum Tween.TransitionType] for highlight animation.
@export var animation_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		if animation_trans != val:
			animation_trans = val
#endregion


#region Private Methods
var _index : int = -1
var _highlight : ColorRect
var _highlight_tween : Tween
#endregion


#region Private Virtual Methods
func _init() -> void:
	_highlight = ColorRect.new()
	add_child(_highlight)

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_position_highlight()
#endregion


#region Private Methods
func _kill_highlight_tween() -> void:
	if _highlight_tween && _highlight_tween.is_running():
		_highlight_tween.kill()
func _position_highlight() -> void:
	_kill_highlight_tween()
	
	fit_child_in_rect(_highlight, get_highlight_rect(_index))
func _animate_highlight(idx : int) -> void:
	_kill_highlight_tween()
	
	_highlight.position.y = 0
	
	_highlight_tween = create_tween()
	_highlight_tween.set_ease(animation_ease)
	_highlight_tween.set_trans(animation_trans)
	_highlight_tween.tween_property(
		_highlight,
		"position:x",
		get_highlight_rect(idx).position.x,
		animation_speed
	)
#endregion


#region Public Methods
## Sets the color of the highlight
func set_color(color : Color) -> void:
	_highlight.color = color

## Moves the highlight to the given vaild index.
## [br][br]
## The [param idx] is clamped to a vaild index. If [code]animate[/code] is true
## the node will animated the transition between pages. 
func goto_index(idx : int, animate : bool) -> void:
	idx = clampi(idx, 0, tab_number)
	if _index == idx:
		return
	
	_index = idx
	start_transition.emit()
	
	if animate:
		_animate_highlight(idx)
	else:
		_position_highlight()	
	
	end_transition.emit()

# Gets the [Rect2] of the highlight.
func get_highlight_rect(idx : int) -> Rect2:
	if 0 > idx || idx >= tab_number:
		return Rect2()
	
	var tab_width := size.x / tab_number
	
	return Rect2(
		Vector2(tab_width * idx, 0),
		Vector2(tab_width, size.y),
	)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
