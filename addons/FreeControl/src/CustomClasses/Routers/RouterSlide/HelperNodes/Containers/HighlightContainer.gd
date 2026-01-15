# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## Used to animate and hold the highlight for the [RouterSlide] node.


#region Export Variables
@export_group("Info")
## All shared info about this router
@export var router_info : RouterSlideInfo:
	set(val):
		if router_info != val:
			if router_info:
				router_info.changed_size.disconnect(_on_size_changed)
				router_info.changed_idx.disconnect(_on_index_changed)
			router_info = val
			if router_info:
				router_info.changed_size.connect(_on_size_changed)
				router_info.changed_idx.connect(_on_index_changed)
			
			if is_node_ready():
				_on_info_update()

@export_group("Appearence")
## The soild color of the highlight.
@export var highlight_color : Color:
	set(val):
		highlight_color = val
		if is_node_ready():
			_highlight.color = highlight_color

@export_group("Animation")
## Length of time for the highlight to animate.
@export_range(0.001, 5, 0.001, "or_greater", "suffix:sec") var animation_speed : float = 0.4:
	set(val):
		val = maxf(val, 0.001)
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


#region Private Variables
var _highlight_tween : Tween
var _highlight : ColorRect
#endregion



#region Virtual Methods
func _init() -> void:
	_highlight = ColorRect.new()
	add_child(_highlight)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_on_size_changed()
#endregion


#region Private Methods (Animation)
func _kill_tween() -> void:
	if _highlight_tween:
		_highlight_tween.kill()
func _force_highlight() -> void:
	_kill_tween()
	
	_highlight.position = get_highlight_rect().position
func _animate_highlight() -> void:
	_kill_tween()
	
	_highlight_tween = create_tween()
	_highlight_tween.set_ease(animation_ease)
	_highlight_tween.set_trans(animation_trans)
	_highlight_tween.tween_property(
		_highlight,
		"position",
		get_highlight_rect().position,
		animation_speed
	)
#endregion


#region Private Methods (Info Update)
func _on_info_update() -> void:
	if !router_info:
		return
	
	_on_size_changed()
	_on_index_changed(-1, router_info.get_index(), false)
func _on_size_changed() -> void:
	_kill_tween()
	if !router_info:
		return
	
	fit_child_in_rect(_highlight, get_highlight_rect())
func _on_index_changed(_old_idx : int, _new_idx : int, use_animation : bool) -> void:
	if !use_animation:
		_force_highlight()
		return
	_animate_highlight()
#endregion


#region Public Accessor Methods
## Returns the tab idx of the highlight is currently on, even
## while animating.
func get_current_index() -> int:
	if !router_info || !router_info.is_empty():
		return 0
	return roundi(position.x / router_info.size())

## Returns the [Rect2] of the highlight.
func get_highlight_rect() -> Rect2:
	if !router_info || !router_info.is_empty():
		return Rect2()
	
	var tab_width := size.x / router_info.size()
	return Rect2(
		Vector2(tab_width * router_info.get_index(), 0),
		Vector2(tab_width, size.y),
	)
#endregion
