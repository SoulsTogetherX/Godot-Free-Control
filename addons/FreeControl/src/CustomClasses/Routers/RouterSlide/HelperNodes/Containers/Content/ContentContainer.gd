# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends Container
## Used to animate and hold the content for the [RouterSlide] node.


#region Export Variables
@export_group("Info")
## All shared info about this router
@export var router_info : RouterSlideInfo:
	set(val):
		if router_info != val:
			if router_info:
				router_info.changed_idx.disconnect(_on_index_changed)
				router_info.changed_size.disconnect(_on_size_changed)
			router_info = val
			if router_info:
				router_info.changed_idx.connect(_on_index_changed)
				router_info.changed_size.connect(_on_size_changed)
			
			if is_node_ready():
				_on_info_update()

@export_group("Animation")
## Length of time for the pages to animate.
@export_range(0.001, 5, 0.001, "or_greater", "suffix:sec") var animation_speed : float = 0.4:
	set(val):
		val = maxf(val, 0.001)
		if animation_speed != val:
			animation_speed = val
## The [enum Tween.EaseType] for the pages' animation.
@export var animation_ease : Tween.EaseType = Tween.EASE_OUT:
	set(val):
		if animation_ease != val:
			animation_ease = val
## The [enum Tween.TransitionType] for the pages' animation.
@export var animation_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		if animation_trans != val:
			animation_trans = val
#endregion


#region Private Variables
var _page_slide_tween : Tween

var _page_slide : Container

var _remove_lambda := Callable()
#endregion



#region Virtual Methods
func _init() -> void:
	_page_slide = preload(RouterSlide.PAGE_SLIDE_CONTAINER_UID).new()
	add_child(_page_slide)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			_on_info_update()
		NOTIFICATION_SORT_CHILDREN:
			_position_componets()
#endregion


#region Private Methods (Info Update)
func _on_info_update() -> void:
	_page_slide.router_info = router_info
	if !router_info:
		return
	
	_on_index_changed(-1, router_info.get_index(), false)
	_on_size_changed()
func _on_index_changed(old_idx : int, new_idx : int, use_animation : bool) -> void:
	if !use_animation:
		_force_pages(old_idx, new_idx)
		return
	_animate_pages(old_idx, new_idx)
func _on_size_changed() -> void:
	queue_sort()
#endregion


#region Private Methods (Animation)
func _kill_tween() -> void:
	if _page_slide_tween:
		_page_slide_tween.kill()
		_call_remove_lambda()
func _force_pages(from : int, to : int) -> void:
	_kill_tween()
	_page_slide.position = Vector2(get_slide_offset(), 0)
	_page_slide.force_pages(from, to)
func _animate_pages(from : int, to : int) -> void:
	_kill_tween()
	
	_remove_lambda = _page_slide.remove_pages.bind(from, to)
	
	_page_slide_tween = create_tween()
	_page_slide_tween.set_ease(animation_ease)
	_page_slide_tween.set_trans(animation_trans)
	
	_page_slide_tween.tween_callback(_page_slide.add_pages.bind(from, to))
	_page_slide_tween.tween_property(
		_page_slide,
		"position",
		Vector2(get_slide_offset(), 0),
		animation_speed
	)
	_page_slide_tween.tween_callback(_call_remove_lambda)

func _call_remove_lambda() -> void:
	if _remove_lambda.is_valid():
		_remove_lambda.call()
		_remove_lambda = Callable()
#endregion


#region Private Methods (Positioning)
func _position_componets() -> void:
	_kill_tween()
	if !router_info:
		return
	
	fit_child_in_rect(_page_slide, Rect2(
		Vector2(get_slide_offset(), 0),
		Vector2(size.x * router_info.size(), size.y)
	))
#endregion


#region Public Methods (Accessor)
## Gets the page index of the closet page to the screen's center.
func get_current_idx() -> int:
	return roundi(_page_slide.position.x / size.x)
## Gets the slide offset of the page router.
func get_slide_offset() -> float:
	if !router_info:
		return 0.0
	return -(size.x * router_info.get_index())
#endregion


#region Public Methods (Page)
## Gets the indexs of all currently visible page nodes.
func get_visible_pages() -> Array[int]:
	return _page_slide.get_visible_pages()

## Gets the page node associated with given page [param idx]. 
func get_page_node(idx : int) -> Page:
	return _page_slide.get_page_node(idx)
#endregion
