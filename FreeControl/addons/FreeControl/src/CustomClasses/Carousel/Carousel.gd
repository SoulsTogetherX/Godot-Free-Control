# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name Carousel extends Container
## A container for Carousel Display of [Control] nodes.

#region Signals
## This signal is emited when an animation begins.
## [br][br]
## Also see [signal manual_begin] and [signal snap_begin].
signal animation_begin
## This signal is emited when an animation reaches it's destination.
## [br][br]
## Also see [signal manual_begin] and [signal snap_begin].
signal animation_end

## This signal is emited when a manual animation begins.
## [br][br]
## Also see [method next], [method prev], and [method go_to_index].
signal manual_begin
## This signal is emited when a manual animation reaches it's destination.
## [br][br]
## Also see [method next], [method prev], and [method go_to_index].
signal manual_end

## This signal is emited when a snap begins.
signal snap_begin
## This signal is emited when a snap reaches it's destination.
signal snap_end

## This signal is emited when a drag begins.
signal drag_begin
## This signal is emited when a drag finishes. This does not include the slowdown caused when [member hard_stop] is [code]false[/code].
signal drag_end

## This signal is emited when the slowdown, caused when [member hard_stop] is [code]false[/code], has started at the end of a drag.
signal slowdown_start
## This signal is emited when the slowdown, caused when [member hard_stop] is [code]false[/code], finished naturally.
signal slowdown_end
#endregion


#region Enums
## Changes the behavior of how draging scrolls the carousel items. Also see [member snap_carousel_transtion_type], [member snap_carousel_ease_type], and [member paging_requirement].
enum SNAP_BEHAVIOR {
	NONE = 0b00, ## No behavior.
	SNAP = 0b01, ## Once drag is released, the carousel will snap to the nearest item.
	PAGING = 0b10 ## Carousel items will not scroll when dragged, unless [member paging_requirement] threshold is met. [member hard_stop] will be assumed as [code]true[/code] for this.
}
## Changes the direction the carousel will animate towards an item. Does not work if [member allow_loop] is [code]false[/code].
enum ANiMATE_DIRECTION {
	AUTO = 0b00, ## Will automatically chose the shortest direction to reach an item.
	LEFT = 0b01, ## Will always move left to reach an item. 
	RIGHT = 0b10 ## Will always move right to reach an item.
}
## Changes how this node adjusts the scroll when the item spacing changed.
enum ADJUST_SCROLL_BEHAVIOR {
	NONE = 0b00, ## No adjustment.
	PROPORTIONAL = 0b01, ## Multiplies the current scroll by the ratio of the old over the next item difference.
	INDEX_SNAP = 0b10, ## Snaps the scroll to the nearest item's center.
	INSTANT = 0b11 ## Instantly snaps the scroll to the nearest item's center.
}
## Internel enum used to differentiate what animation is currently playing
enum ANIMATION_TYPE {
	NONE = 0b00, ## No behavior.
	MANUAL = 0b01, ## Currently animating via request by [method go_to_index].
	SNAP = 0b10, ## Currently animating via an auto-item snapping request.
}
#endregion


#region External Variables
@export_group("Carousel Options")
## The index of the item this carousel will start at.
@export var starting_index : int = 0:
	set(val):
		if !_item_infos.is_empty():
			val = posmod(val, _item_infos.size())
		if val != starting_index:
			starting_index = val
			
			if is_node_ready():
				go_to_index(starting_index, false)
## The size of each item in the carousel.
@export var item_size : Vector2 = Vector2(200, 200):
	set(val):
		if val != item_size:
			if is_node_ready():
				_reconfigure_distance(item_seperation, carousel_angle, val)
				item_size = val
				
				queue_sort()
				return
			
			item_size = val
## The space between each item in the carousel.
@export_range(0, 100, 0.001, "or_less", "or_greater", "suffix:px") var item_seperation : float = 0:
	set(val):
		if val != item_seperation:
			if is_node_ready():
				_reconfigure_distance(val, carousel_angle, item_size)
				item_seperation = val
				
				_adjust_children()
				return
			
			item_seperation = val
## The orientation the carousel items will be displayed in.
@export_range(0, 360, 0.001, "or_less", "or_greater", "suffix:deg") var carousel_angle : float = 0.0:
	set(val):
		if val != carousel_angle:
			if is_node_ready():
				_reconfigure_distance(item_seperation, val, item_size)
				carousel_angle = val
				
				_adjust_children()
				return
			
			carousel_angle = val
## The distance between any two items on the carousel is dependent on [member item_size],
## [member carousel_angle], and [member item_seperation].[br]
## This variable determines how the current scroll will be adjusted to accommodate the
## change in item distance.
@export var dynamic_scroll_behavior : ADJUST_SCROLL_BEHAVIOR = ADJUST_SCROLL_BEHAVIOR.INDEX_SNAP

@export_group("Loop Options")
## Allows looping from the last item to the first and vice versa.
## [br][br]
## [b]NOTE[/b]: if [member display_loop] is [code]true[/code], [member enforce_border]
## is [code]false[/code], and [member snap_behavior] is [code]SNAP_BEHAVIOR.NONE[/code],
## then [member allow_loop] is considered [code]true[/code].
@export var allow_loop : bool = true
## If [code]true[/code], the carousel will display it's items as if looping. Otherwise, the items will not loop.
## [br][br]
## also see [member enforce_border] and [member border_limit].
@export var display_loop : bool = true:
	set(val):
		if val != display_loop:
			display_loop = val
			
			if is_node_ready():
				_adjust_children()
## The number of items, surrounding the current item of the current index, that will be visible.
## If [code]-1[/code], all items will be visible.
@export_range(-1, 10, 1, "or_greater") var display_range : int = -1:
	set(val):
		val = maxi(-1, val)
		if val != display_range:
			display_range = val
			
			if is_node_ready():
				_adjust_children()

@export_group("Snap")
## Assigns the behavior of how draging scrolls the carousel items. Also see [member snap_carousel_transtion_type], [member snap_carousel_ease_type], and [member paging_requirement].
@export var snap_behavior : SNAP_BEHAVIOR = SNAP_BEHAVIOR.SNAP:
	set(val):
		if val != snap_behavior:
			snap_behavior = val
			
			notify_property_list_changed()
## If [member snap_behavior] is [code]SNAP_BEHAVIOR.PAGING[/code], this is the draging threshold needed to page to the next carousel item.
@export_range(0, 100, 0.001, "or_greater", "hide_slider", "suffix:px") var paging_requirement : float = 200:
	set(val):
		val = maxf(0, val)
		if val != paging_requirement:
			paging_requirement = val
## If [code]true[/code], then there will be no snapping animation between each pagging.
## [br][br]
## Also see [member snap_behavior] and [member paging_requirement].
@export var page_with_animation : bool = true

@export_group("Animation Options")
@export_subgroup("Manual")
## The duration of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export_range(0.001, 2.0, 0.001, "or_greater", "suffix:sec") var manual_carousel_duration : float = 0.4:
	set(val):
		val = maxf(0.001, val)
		if val != manual_carousel_duration:
			manual_carousel_duration = val
## The [enum Tween.TransitionType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_transtion_type : Tween.TransitionType
## The [enum Tween.EaseType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_ease_type : Tween.EaseType

@export_subgroup("Snap")
## The duration of the animation when snapping to an item.
@export_range(0.001, 2.0, 0.001, "or_greater", "suffix:sec") var snap_carousel_duration : float = 0.2:
	set(val):
		val = maxf(0.001, val)
		if val != snap_carousel_duration:
			snap_carousel_duration = val
## The [enum Tween.TransitionType] of the animation when snapping to an item.
@export var snap_carousel_transtion_type : Tween.TransitionType
## The [enum Tween.EaseType] of the animation when snapping to an item.
@export var snap_carousel_ease_type : Tween.EaseType

@export_group("Drag")
## If [code]true[/code], the user is allowed to drag via their mouse or touch.
@export var can_drag : bool = true:
	set(val):
		if val != can_drag:
			can_drag = val
			
			notify_property_list_changed()
## If [code]true[/code], the user is allowed to drag outisde the drawer's bounding box.
## Otherwise, drag is auto cancled.
## [br][br]
## Also see [member can_drag].
@export var drag_outside : bool = true
@export_subgroup("Limits")
## The max amount a user can drag in either direction. If [code]0[/code], then the user can drag any amount they wish.
@export_range(0, 100, 1, "or_less", "or_greater", "suffix:px") var drag_limit : float = 0
## When dragging, the user will not be able to move past the last or first item, besides for [member border_limit] number of extra pixels.
## [br][br]
## This value is assumed [code]false[/code] is [member display_loop] is [code]true[/code].
@export var enforce_border : bool = false:
	set(val):
		if val != enforce_border:
			enforce_border = val
			if enforce_border:
				_adjust_children()
			
			notify_property_list_changed()
## The amount of extra pixels a user can drag past the last and before the first item in the carousel.
## [br][br]
## This property does nothing if enforce_border is [code]false[/code].
@export_range(0, 100, 1, "or_less", "or_greater", "suffix:px") var border_limit : float = 0:
	set(val):
		if val != border_limit:
			border_limit = val
			if enforce_border:
				_adjust_children()
			
			notify_property_list_changed()

@export_subgroup("Slowdown")
## If [code]true[/code] the carousel will immediately stop when not being dragged. Otherwise, drag speed will be gradually decreased.
## [br][br]
## This property is assumed [code]true[/code] if [member snap_behavior] is set to [code]SNAP_BEHAVIOR.PAGING[/code]. Also see [member slowdown_drag], [member slowdown_friction], and [member slowdown_cutoff].
@export var hard_stop : bool = true:
	set(val):
		if val != hard_stop:
			hard_stop = val
			
			notify_property_list_changed()
			if is_node_ready():
				_end_slowdown()
## The percentage multiplier the drag velocity will experience each frame.
## [br][br]
## This property does nothing if [member hard_stop] is [code]true[/code].
@export_range(0.0, 1.0, 0.001) var slowdown_drag : float = 0.9
## The constant decrease the drag velocity will experience each frame.
## [br][br]
## This property does nothing if [member hard_stop] is [code]true[/code].
@export_range(0.0, 5.0, 0.001, "or_greater", "hide_slider") var slowdown_friction : float = 0.1
## The cutoff amount. If drag velocity magnitude drops below this amount, the slowdown has finished.
## [br][br]
## This property does nothing if [member hard_stop] is [code]true[/code].
@export_range(0.01, 10.0, 0.001, "or_greater", "hide_slider") var slowdown_cutoff : float = 0.01
#endregion


#region Private Variables
var _distance_cache : float

var _scroll_delta : float
var _scroll_tween : Tween

var _drag_delta : float
var _is_dragging : bool
var _drag_input_stopper : bool

var _drag_velocity : float

var _index : int
var _item_infos : Array[ItemInfo]

var _current_animation := ANIMATION_TYPE.NONE
#endregion


#region Private Virtual Methods
func _validate_property(property: Dictionary) -> void:
	if property.name == "border_limit":
		if !enforce_border:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name in ["paging_requirement", "page_with_animation"]:
		if snap_behavior != SNAP_BEHAVIOR.PAGING:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "hard_stop":
		if snap_behavior == SNAP_BEHAVIOR.PAGING:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name in ["slowdown_drag", "slowdown_friction", "slowdown_cutoff"]:
		if hard_stop || snap_behavior == SNAP_BEHAVIOR.PAGING:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name in ["drag_outside"]:
		if !can_drag:
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY:
			_settup_children()
			_reconfigure_distance(item_seperation, carousel_angle, item_size)
			
			go_to_index(starting_index, false)
		NOTIFICATION_EXIT_TREE:
			_end_slowdown()
		NOTIFICATION_MOUSE_EXIT:
			_outside_drag_check()
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenDrag || event is InputEventMouseMotion):
		if _is_dragging:
			# Prevents drag from handled multiple times in a single frame.
			if _drag_input_stopper:
				return
			_drag_input_stopper = true
			set_deferred("_drag_input_stopper", false)
			
			# Handles the drag
			_handle_drag_angle(event.relative)
	elif (event is InputEventScreenTouch || event is InputEventMouseButton):
		if event.pressed:
			if !drag_outside && !get_viewport_rect().has_point(event.position):
				return
			
			_start_drag()
			return
		_end_drag()


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
#endregion


#region Custom Virtual Methods
## A virtual function that is is called whenever the scroll changes.
## [br][br]
## [param ratio] is the ratio, between 0 to 1, of how far the carousel has been
## fully rotated across.
## [br][br]
## Also see [method get_scroll_ratio].
func _on_progress(ratio : float) -> void:
	pass
## A virtual function that is is called whenever the scroll changes, for each visible
## item in the carousel.
## [br][br]
## [param item] is the item that is being operated on.[br]
## [param index] is the index of the item in the scene tree, compared to another
## [Control] nodes. (see [method get_carousel_index])[br]
## [param local_index] is the index relative to the currently-viewed index
## (see [method get_current_carousel_index]).[br]
## [param scroll] is the current scroll.[br]
## [param scroll_offset] is the current scroll offset between the current and the next index.
func _on_item_progress(item : Control, index : int, local_index : int, scroll : float, scroll_offset : float) -> void:
	pass
#endregion


#region Private Methods (Helper Methods)
func _get_child_rect(child : Control) -> Rect2:
	var child_pos : Vector2
	var child_size : Vector2
	var min_size := child.get_combined_minimum_size()
	
	match child.size_flags_horizontal:
		SIZE_FILL:
			child_pos.x = (size.x - item_size.x) * 0.5
			child_size.x = item_size.x
		SIZE_SHRINK_BEGIN:
			child_pos.x = (size.x - item_size.x) * 0.5
		SIZE_SHRINK_CENTER:
			child_pos.x = (size.x - min_size.x) * 0.5
		SIZE_SHRINK_END:
			child_pos.x = (size.x + item_size.x) * 0.5 - min_size.x
	match child.size_flags_vertical:
		SIZE_FILL:
			child_pos.y = (size.y - item_size.y) * 0.5
			child_size.y = item_size.y
		SIZE_SHRINK_BEGIN:
			child_pos.y = (size.y - item_size.y) * 0.5
		SIZE_SHRINK_CENTER:
			child_pos.y = (size.y - min_size.y) * 0.5
		SIZE_SHRINK_END:
			child_pos.y = (size.y + item_size.y) * 0.5 - min_size.y
	
	return Rect2(child_pos, child_size)
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control))
	return ret


func _is_allow_loop() -> bool:
	return allow_loop || (display_loop && !enforce_border && snap_behavior == SNAP_BEHAVIOR.NONE)


func _calculate_item_offset(angle : float, item_s : Vector2) -> Vector2:
	var angle_mod := deg_to_rad((180 - absf(2 * fposmod(angle, 180) - 180)) * 0.5)
	return Vector2(
		item_s.y / tan(angle_mod),
		item_s.x * tan(angle_mod)
	).min(item_s)

func _scroll_to_index(scroll : float) -> int:
	if _item_infos.is_empty(): 
		return -1
	return roundi(scroll / _distance_cache)
func _index_to_scroll(index : int) -> float:
	if _item_infos.is_empty(): 
		return 0.0
	return index * _distance_cache
#endregion


#region Private Methods (Calibration Methods)
func _reconfigure_drag() -> void:
	_scroll_delta = get_adjusted_scroll(true)
	_drag_delta = 0
func _reconfigure_index() -> void:
	_index = _scroll_to_index(_scroll_delta)
func _reconfigure_distance(seperation : float, angle : float, item_s : Vector2) -> void:
	if _distance_cache != 0:
		_reconfigure_drag()
	
	var new_distance := _calculate_item_offset(angle, item_s).length() + seperation
	if dynamic_scroll_behavior == ADJUST_SCROLL_BEHAVIOR.PROPORTIONAL:
		_scroll_delta = 0 if _distance_cache == 0 else _scroll_delta * (new_distance / _distance_cache)
		_distance_cache = new_distance
		_reconfigure_index()
		return

	_distance_cache = new_distance
	if dynamic_scroll_behavior == ADJUST_SCROLL_BEHAVIOR.INSTANT:
		go_to_index(_index, false)
	elif dynamic_scroll_behavior == ADJUST_SCROLL_BEHAVIOR.INDEX_SNAP && !is_animating():
		go_to_index(_index, true)
#endregion


#region Private Methods (Sorter Methods)
func _sort_children() -> void:
	_settup_children()
	_adjust_children()
func _settup_children() -> void:
	var children : Array[Control] = _get_control_children()
	var item_count = children.size()
	
	_item_infos.resize(item_count)
	
	# Sets up the rect for each item
	for i : int in range(0, item_count):
		var item_info := ItemInfo.new()
		
		item_info.node = children[i]
		item_info.rect = _get_child_rect(children[i])
		
		_item_infos[i] = item_info
func _adjust_children() -> void:
	if _item_infos.is_empty():
		return
	
	# Gathers variables
	var axis_angle := Vector2.RIGHT.rotated(deg_to_rad(carousel_angle))
	
	var item_count := _item_infos.size()
	
	var scroll := get_adjusted_scroll(true)
	var index_delta := (scroll / _distance_cache)
	var index_offset := floori(index_delta)
	var scroll_offset := fmod(scroll, _distance_cache)
	
	# Calls custom virtual method
	_on_progress(scroll / _distance_cache)
	
	if display_loop:
		var mid_index : int = floori(item_count * 0.5)
		for idx : int in item_count:
			var info := _item_infos[idx]
			var offset_rect := info.rect
			
			# Gets the local index of the item according to the loop
			var local_index := posmod(idx - index_offset, item_count)
			local_index -= item_count * int(local_index > mid_index)
			
			# Changes item visibility if outside range
			info.node.visible = display_range == -1 || (absi(local_index) <= display_range)
			
			offset_rect.position += axis_angle * (_distance_cache * local_index - scroll_offset)
			fit_child_in_rect(info.node, offset_rect)
			_on_item_progress(info.node, idx, local_index, scroll, scroll_offset)
	else:
		var index_current := roundi(index_delta)
		for idx : int in item_count:
			var info := _item_infos[idx]
			var offset_rect := info.rect
			
			# Changes item visibility if outside range
			info.node.visible = display_range == -1 || (absi(idx - _index) <= display_range)
			
			offset_rect.position += axis_angle * (_distance_cache * (idx - index_offset) - scroll_offset)
			fit_child_in_rect(info.node, offset_rect)
			_on_item_progress(info.node, idx, idx - index_current, scroll, scroll_offset)
 #endregion


#region Private Methods (Animation Methods)
func _kill_animation() -> void:
	if _scroll_tween && _scroll_tween.is_running():
		_scroll_tween.kill()
func _on_animation_finished() -> void:
	_reconfigure_index()
	
	animation_end.emit()
	match _current_animation:
		ANIMATION_TYPE.MANUAL:
			manual_end.emit()
		ANIMATION_TYPE.SNAP:
			snap_end.emit()
	_current_animation = ANIMATION_TYPE.NONE
func _create_animation(idx : int, animation_type : ANIMATION_TYPE, animate_direction : ANiMATE_DIRECTION = ANiMATE_DIRECTION.AUTO) -> void:
	_reconfigure_drag()
	_kill_animation()

	# Gathering Variables
	var idx_delta := 0 if _distance_cache == 0 else _scroll_delta / _distance_cache
	if _is_allow_loop():
		idx = posmod(idx, _item_infos.size())
	else:
		idx = clampf(idx, 0, _item_infos.size() - 1)
	
	# Checks if it needs to loop around, and which way it needs to loop if so.
	if _is_allow_loop() && display_loop:
		var item_count := _item_infos.size()
		
		match animate_direction:
			ANiMATE_DIRECTION.AUTO:
				# Loops if distance is shorter when looping.
				if absi(idx_delta - idx) > (item_count * 0.5):
					var left_distance := posmod(idx_delta - idx, item_count)
					var right_distance := posmod(idx - idx_delta, item_count)
					
					if left_distance < right_distance:
						idx -= item_count
					else:
						idx += item_count
			ANiMATE_DIRECTION.LEFT:
				# Always loop left if needed.
				if idx_delta < idx:
					idx = posmod(idx, item_count) - item_count
			ANiMATE_DIRECTION.RIGHT:
				# Always loop right if needed.
				if idx_delta > idx:
					idx = posmod(idx, item_count) + item_count
	
	if _current_animation != ANIMATION_TYPE.NONE:
		animation_end.emit()
		match _current_animation:
			ANIMATION_TYPE.MANUAL:
				manual_end.emit()
			ANIMATION_TYPE.SNAP:
				snap_end.emit()
	
	_current_animation = animation_type
	animation_begin.emit()
	
	# Creates tween
	_scroll_tween = create_tween()
	match animation_type:
		ANIMATION_TYPE.MANUAL:
			manual_begin.emit()
			_scroll_tween.set_ease(manual_carousel_ease_type)
			_scroll_tween.set_trans(manual_carousel_transtion_type)
		ANIMATION_TYPE.SNAP:
			snap_begin.emit()
			_scroll_tween.set_ease(snap_carousel_ease_type)
			_scroll_tween.set_trans(snap_carousel_transtion_type)
	
	# Starts tween
	_scroll_tween.tween_method(
		_animation_method,
		idx_delta,
		idx,
		manual_carousel_duration
	)
	
	# Calls animation finish method
	_scroll_tween.tween_callback(_on_animation_finished)
func _animation_method(delta : float) -> void:
	_scroll_delta = _distance_cache * delta
	_adjust_children()
#endregion


#region Private Methods (Drag Methods)
func _handle_drag_angle(local_pos : Vector2) -> void:
	var angle_vec := Vector2.RIGHT.rotated(deg_to_rad(carousel_angle))
	var projected_scalar := -local_pos.dot(angle_vec) / angle_vec.length_squared()
	
	_drag_velocity = projected_scalar
	
	if drag_limit == 0:
		_drag_delta += projected_scalar
	else:
		_drag_delta = clampi(_drag_delta + projected_scalar, -drag_limit, drag_limit)
	
	if snap_behavior == SNAP_BEHAVIOR.PAGING:
		if paging_requirement < _drag_delta:
			_drag_delta = 0
			_index += 1
			
			if page_with_animation:
				_create_animation(_index, ANIMATION_TYPE.SNAP, ANiMATE_DIRECTION.RIGHT)
				return
			
			_scroll_delta = _index_to_scroll(_index)
		elif -paging_requirement > _drag_delta:
			_drag_delta = 0
			_index -= 1
			
			if page_with_animation:
				_create_animation(_index, ANIMATION_TYPE.SNAP, ANiMATE_DIRECTION.LEFT)
				return
			
			_scroll_delta = _index_to_scroll(_index)
	
	_adjust_children()

func _outside_drag_check() -> void:
	if !drag_outside && _is_dragging:
		_end_drag()

func _end_drag() -> void:
	if !_is_dragging:
		return
	
	_is_dragging = false
	_reconfigure_drag()
	_reconfigure_index()
	
	drag_end.emit()
	
	if !hard_stop:
		_start_slowdown()
		return
	if snap_behavior == SNAP_BEHAVIOR.SNAP:
		_create_animation(_index, ANIMATION_TYPE.SNAP)
func _start_drag() -> void:
	if _is_dragging:
		return
	
	_is_dragging = true
	_end_slowdown()
	_kill_animation()
	
	drag_begin.emit()
#endregion


#region Private Methods (Slowdown Methods)
func _end_slowdown() -> void:
	if !get_tree().process_frame.is_connected(_handle_slowdown):
		return
	
	get_tree().process_frame.disconnect(_handle_slowdown)
	_reconfigure_index()
	_drag_velocity = 0
	slowdown_end.emit()
	
	if snap_behavior == SNAP_BEHAVIOR.SNAP:
		_create_animation(_index, ANIMATION_TYPE.SNAP)
func _start_slowdown() -> void:
	if get_tree().process_frame.is_connected(_handle_slowdown):
		return
	get_tree().process_frame.connect(_handle_slowdown)
	
	slowdown_start.emit()
func _handle_slowdown() -> void:
	if absf(_drag_velocity) < slowdown_cutoff:
		_drag_velocity = 0
		_end_slowdown()
		return
	
	if _drag_velocity > 0:
		_drag_velocity = maxf(0., _drag_velocity - slowdown_friction)
	else:
		_drag_velocity = minf(0., _drag_velocity + slowdown_friction)
	_drag_velocity *= slowdown_drag
	_scroll_delta += _drag_velocity
	_adjust_children()
#endregion


#region Public Methods (Movement Methods)
## Moves to an item of the given index within the carousel. If an invalid index is given, it will be posmod into a vaild index.
func go_to_index(idx : int, animation : bool = true, animation_direction : ANiMATE_DIRECTION = ANiMATE_DIRECTION.AUTO) -> void:
	if _item_infos.is_empty():
		return
	var item_count := _item_infos.size()
	_index = posmod(idx, item_count) if _is_allow_loop() else clampi(idx, 0, item_count - 1)
	
	if animation:
		_create_animation(_index, ANIMATION_TYPE.MANUAL, animation_direction)
		return
	_scroll_delta = _distance_cache * _index
	_adjust_children()
## Moves to the previous item in the carousel, if there is one.
func prev(animation : bool = true, animation_direction : ANiMATE_DIRECTION = ANiMATE_DIRECTION.AUTO) -> void:
	_reconfigure_drag()
	_reconfigure_index()
	go_to_index(_index - 1, animation, animation_direction)
## Moves to the next item in the carousel, if there is one.
func next(animation : bool = true, animation_direction : ANiMATE_DIRECTION = ANiMATE_DIRECTION.AUTO) -> void:
	_reconfigure_drag()
	_reconfigure_index()
	go_to_index(_index + 1, animation, animation_direction)


## Enacts a manual drag on the carousel. This can be used even if [member can_drag] is [code]false[/code].
## Note that [param from] and [param dir] are considered in local coordinates.
## [br][br]
## Is not affected by [member hard_stop], [member drag_outside], and [member drag_limit].
func flick(from : Vector2, dir : Vector2) -> void:
	_start_drag()
	_handle_drag_angle(dir - from)
	_end_drag()
#endregion


#region Public Methods (Value Access Methods)
## Returns if the carousel is currening scrolling via na animation
func is_animating() -> bool:
	return false
## Returns if the carousel is currening being dragged by player input.
func is_dragged() -> bool:
	return _is_dragging


## Gets the index of the last confirmed frontmost item.
## [br][br]
## [b]NOTE[/b]: This is not always accurate to what is actually shown. For
## A real-time update, use [method get_current_carousel_index].
func get_carousel_index() -> int:
	return _index
## Gets the current index of the frontmost item.
func get_current_carousel_index(with_drag : bool = false, with_clamp : bool = true) -> int:
	return _scroll_to_index(
		get_adjusted_scroll(with_drag) if with_clamp else get_scroll(with_drag)
	)


## Returns the [Vector2] offset each item is placed at from each other.
## [br][br]
## [b]NOTE[/b]: This does not include [member item_seperation].
func get_item_offset() -> Vector2:
	return _calculate_item_offset(carousel_angle, item_size)
## Returns the pixel distance each item is placed at from each other (including item_seperation).
func get_item_distance() -> float:
	return _distance_cache
## Returns the number of items on this carousel.
func get_item_count() -> int:
	return _item_infos.size()


## Returns the adjusted scroll delta.[br]
## Returns [code]-1[/code] if this [Carousel] has no items on it.
## [br][br]
## Also see [member enforce_border], [member border_limit], and [member allow_loop].
func get_adjusted_scroll(with_drag : bool = false) -> float:
	if _item_infos.is_empty():
		return 0
	
	var ret := _scroll_delta
	if with_drag && snap_behavior != SNAP_BEHAVIOR.PAGING:
		ret += _drag_delta
	
	if _is_allow_loop():
		ret = posmod(ret, _distance_cache * _item_infos.size())
	elif enforce_border:
		ret = clampf(ret, -border_limit, _distance_cache * (_item_infos.size() - 1) + border_limit)
	return ret
## Returns the scroll delta within a ratio from 0 to 1 (inclusive).[br]
## Returns [code]-1[/code] if this [Carousel] has no items on it.
func get_scroll_ratio(with_drag : bool = false) -> float:
	if _item_infos.is_empty():
		return -1
	return get_scroll(with_drag) / _distance_cache
## Returns the raw scroll delta.[br]
## Returns [code]-1[/code] if this [Carousel] has no items on it.
func get_scroll(with_drag : bool = false) -> float:
	if _item_infos.is_empty():
		return -1
	
	if with_drag:
		return _scroll_delta + _drag_delta
	return _scroll_delta
#endregion


#region Subclasses
# Used to hold data about a carousel item
class ItemInfo:
	var node : Control
	var rect : Rect2
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
