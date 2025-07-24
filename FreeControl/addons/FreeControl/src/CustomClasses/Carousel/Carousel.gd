# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name Carousel extends Container
## A container for Carousel Display of [Control] nodes.

#region Signals
## This signal is emited when a snap reaches it's destination.
signal snap_end
## This signal is emited when a snap begins.
signal snap_begin
## This signal is emited when a drag finishes. This does not include the slowdown caused when [member hard_stop] is [code]false[/code].
signal drag_end
## This signal is emited when a drag begins.
signal drag_begin
## This signal is emited when the slowdown, caused when [member hard_stop] is [code]false[/code], finished naturally.
signal slowdown_end
## This signal is emited when the slowdown, caused when [member hard_stop] is [code]false[/code], is interrupted by another drag or other feature. 
signal slowdown_interupted
#endregion


#region Enums
## Changes the behavior of how draging scrolls the carousel items. Also see [member snap_carousel_transtion_type], [member snap_carousel_ease_type], and [member paging_requirement].
enum SNAP_BEHAVIOR {
	NONE = 0b00, ## No behavior.
	SNAP = 0b01, ## Once drag is released, the carousel will snap to the nearest item.x
	PAGING = 0b10 ## Carousel items will not scroll when dragged, unless [member paging_requirement] threshold is met. [member hard_stop] will be assumed as [code]true[/code] for this.
}
## Internel enum used to differentiate what animation is currently playing
enum ANIMATION_TYPE {
	NONE = 0b00, ## No behavior.
	MANUAL = 0b01, ## Currently animating via request by [method go_to_index].
	SNAP = 0b10 ## Currently animating via an auto-item snapping request.
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
				var old_axis := _get_relevant_axis()
				item_size = val
				var new_axis := _get_relevant_axis()
				
				_scroll_delta = (_scroll_delta * new_axis) / old_axis
				_max_scroll = new_axis * _item_infos.size()
				
				queue_sort()
				return
			
			item_size = val
## The space between each item in the carousel.
@export_range(0, 100, 1, "or_less", "or_greater", "suffix:px") var item_seperation : int = 0:
	set(val):
		if val != item_seperation:
			if is_node_ready():
				var old_axis := _get_relevant_axis()
				var new_axis := old_axis - item_seperation + val
				item_seperation = val
				
				_scroll_delta = (_scroll_delta * new_axis) / old_axis
				_max_scroll = new_axis * _item_infos.size()
				_adjust_children()
				return
			
			item_seperation = val
## The orientation the carousel items will be displayed in.
@export_range(0, 360, 0.001, "or_less", "or_greater", "suffix:deg") var carousel_angle : float = 0.0:
	set(val):
		if val != carousel_angle:
			if is_node_ready():
				var old_axis := _get_relevant_axis()
				carousel_angle = val
				var new_axis := _get_relevant_axis()
				
				_scroll_delta = (_scroll_delta * new_axis) / old_axis
				_max_scroll = new_axis * _item_infos.size()
				_adjust_children()
				return
			
			carousel_angle = val

@export_group("Loop Options")
## Allows looping from the last item to the first and vice versa.
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
		val = maxi(val, -1)
		if val != display_range:
			display_range = val
			
			if is_node_ready():
				_adjust_children()

@export_group("Snap")
## Assigns the behavior of how draging scrolls the carousel items. Also see [member snap_carousel_transtion_type], [member snap_carousel_ease_type], and [member paging_requirement].
@export var snap_behavior : SNAP_BEHAVIOR = SNAP_BEHAVIOR.SNAP
## If [member snap_behavior] is [SNAP_BEHAVIOR.PAGING], this is the draging threshold needed to page to the next carousel item.
@export_range(0, 100, 1, "or_greater", "hide_slider", "suffix:px") var paging_requirement : int = 200

@export_group("Animation Options")
@export_subgroup("Manual")
## The duration of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export_range(0.001, 2.0, 0.001, "or_greater", "suffix:sec") var manual_carousel_duration : float = 0.4
## The [enum Tween.TransitionType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_transtion_type : Tween.TransitionType
## The [enum Tween.EaseType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_ease_type : Tween.EaseType

@export_subgroup("Snap")
## The duration of the animation when snapping to an item.
@export_range(0.001, 2.0, 0.001, "or_greater", "suffix:sec") var snap_carousel_duration : float = 0.2
## The [enum Tween.TransitionType] of the animation when snapping to an item.
@export var snap_carousel_transtion_type : Tween.TransitionType
## The [enum Tween.EaseType] of the animation when snapping to an item.
@export var snap_carousel_ease_type : Tween.EaseType

@export_group("Drag")
## If [code]true[/code], the user is allowed to drag via their mouse or touch.
@export var can_drag : bool = true
## If [code]true[/code], the user is allowed to drag outisde the drawer's bounding box.
## [br][br]
## Also see [member can_drag].
@export var drag_outside : bool = false
@export_subgroup("Limits")
## The max amount a user can drag in either direction. If [code]0[/code], then the user can drag any amount they wish.
@export_range(0, 100, 1, "or_less", "or_greater", "suffix:px") var drag_limit : int = 0
## When dragging, the user will not be able to move past the last or first item, besides for [member border_limit] number of extra pixels.
## [br][br]
## This value is assumed [code]false[/code] is [member display_loop] is [code]true[/code].
@export var enforce_border : bool = false
## The amount of extra pixels a user can drag past the last and before the first item in the carousel.
## [br][br]
## This property does nothing if enforce_border is [code]false[/code].
@export_range(0, 100, 1, "or_less", "or_greater", "suffix:px") var border_limit : int = 0

@export_subgroup("Slowdown")
## If [code]true[/code] the carousel will immediately stop when not being dragged. Otherwise, drag speed will be gradually decreased.
## [br][br]
## This property is assumed [code]true[/code] if [member snap_behavior] is set to [SNAP_BEHAVIOR.PAGING]. Also see [member slowdown_drag], [member slowdown_friction], and [member slowdown_cutoff].
@export var hard_stop : bool = true
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
var _max_scroll : int
var _scroll_delta : int
var _scroll_tween : Tween

var _index : int

var _item_infos : Array[ItemInfo]
#endregion


#region Private Virtual Methods
func _validate_property(property: Dictionary) -> void:
	if property.name == "enforce_border":
		if display_loop:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "border_limit":
		if display_loop || !enforce_border:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "paging_requirement":
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
			go_to_index(starting_index, false)
		#NOTIFICATION_EXIT_TREE:
		#	_end_drag_slowdown()
		#NOTIFICATION_MOUSE_EXIT:
		#	_mouse_check()
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _gui_input(event: InputEvent) -> void:
	pass

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
#endregion


#region Custom Virtual Methods
## A virtual function that is is called whenever the scroll changes.
func _on_progress(scroll : int) -> void:
	pass
## A virtual function that is is called whenever the scroll changes, for each visible
## item in the carousel.
## [br][br]
## [param item] is the item that is being operated on.[br]
## [param index] is the index of the item in the scene tree, compared to another
## [Control] nodes. (see [method get_carousel_index])[br]
## [param local_index] is the index relative to the currently-viewed index
## (is the same as [param index] if [member display_loop] is [code]false[/code]).[br]
## [param scroll] is the current scroll.[br]
## [param scroll_offset] is the current scroll offset between the current and the next index.
func _on_item_progress(item : Control, index : int, local_index : int, scroll : int, scroll_offset : int) -> void:
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

func _get_relevant_axis() -> int:
	var angle_mod := deg_to_rad((180 - absf(2 * fposmod(carousel_angle, 180) - 180)) * 0.5)
	var d_vec := Vector2(
		item_size.y / tan(angle_mod),
		item_size.x * tan(angle_mod)
	).min(item_size)
	
	return d_vec.length() + item_seperation

func _reconfigure_scroll() -> void:
	_scroll_delta = get_scroll(true)
#endregion


#region Private Methods (Animation Methods)
func _kill_animation() -> void:
	if _scroll_tween && _scroll_tween.is_running():
		_scroll_tween.kill()
		_on_animation_finished()
func _on_animation_finished() -> void:
	_reconfigure_scroll()
func _create_animation(idx : int, animation_type : ANIMATION_TYPE) -> void:
	_kill_animation()
	if _item_infos.is_empty():
		return
	
	# Gathering Variables
	var axis_distance := _get_relevant_axis()
	var desired_scroll := axis_distance * idx % _max_scroll
	
	# Checks if it needs to loop around, and which way it needs to loop if so.
	if allow_loop && display_loop:
		# Loops if distance is shorter when looping
		if absi(_scroll_delta - desired_scroll) > (_max_scroll >> 1):
			var left_distance := posmod(_scroll_delta - desired_scroll, _max_scroll)
			var right_distance := posmod(desired_scroll - _scroll_delta, _max_scroll)
		
			if left_distance < right_distance:
				desired_scroll -= _max_scroll
			else:
				desired_scroll += _max_scroll
	
	# Starts tween
	_scroll_tween = create_tween()
	_scroll_tween.set_ease(manual_carousel_ease_type)
	_scroll_tween.set_trans(manual_carousel_transtion_type)
	_scroll_tween.tween_method(
		_animation_method,
		_scroll_delta,
		desired_scroll,
		manual_carousel_duration
	)
	
	# Calls animation finish method
	_scroll_tween.tween_callback(_on_animation_finished)
func _animation_method(scroll : int) -> void:
	_scroll_delta = scroll
	_adjust_children()
#endregion


#region Private Methods (Sorter Methods)
func _sort_children() -> void:
	_settup_children()
	_adjust_children()
func _settup_children() -> void:
	var children : Array[Control] = _get_control_children()
	var item_count = children.size()
	
	_item_infos.resize(item_count)
	_max_scroll = _get_relevant_axis() * item_count
	
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
	var axis_distance := _get_relevant_axis()
	var axis_angle := Vector2.RIGHT.rotated(deg_to_rad(carousel_angle))
	
	var item_count := _item_infos.size()
	
	var scroll := get_scroll(true)
	var index_offset := int(scroll / axis_distance) % item_count
	var scroll_offset := scroll % axis_distance
	
	# Calls custom virtual method
	_on_progress(scroll)
	
	if display_loop:
		var mid_index : int = floori(item_count * 0.5)
		for idx : int in item_count:
			var info := _item_infos[idx]
			var offset_rect := info.rect
			
			# Gets the local index of the item according to the loop
			var local_index := posmod(idx - index_offset - mid_index, item_count) - mid_index
			# Changes item visibility if outside range
			info.node.visible = display_range == -1 || (absi(local_index) <= display_range)
			
			offset_rect.position += axis_angle * (axis_distance * local_index - scroll_offset)
			fit_child_in_rect(info.node, offset_rect)
			_on_item_progress(info.node, idx, local_index, scroll, scroll_offset)
	else:
		for idx : int in item_count:
			var info := _item_infos[idx]
			var offset_rect := info.rect
			
			# Changes item visibility if outside range
			info.node.visible = display_range == -1 || (absi(idx - _index) <= display_range)
			
			offset_rect.position += axis_angle * (axis_distance * (idx - index_offset) - scroll_offset)
			fit_child_in_rect(info.node, offset_rect)
			_on_item_progress(info.node, idx, idx, scroll, scroll_offset)
 #endregion


#region Public Methods
func get_carousel_index() -> int:
	return _index
func get_current_carousel_index(with_drag : bool = false, with_clamp : bool = true) -> int:
	return -1

## Moves to an item of the given index within the carousel. If an invalid index is given, it will be posmod into a vaild index.
func go_to_index(idx : int, animation : bool = true) -> void:
	if _item_infos.is_empty():
		return
	
	var item_count := _item_infos.size()
	_index = posmod(idx, item_count) if allow_loop else clampi(idx, 0, item_count - 1)
	
	if animation:
		_create_animation(_index, ANIMATION_TYPE.MANUAL)
		return
	_scroll_delta = _get_relevant_axis() * _index
	_adjust_children()
## Moves to the previous item in the carousel, if there is one.
func prev(animation : bool = true) -> void:
	go_to_index(_index - 1, animation)
## Moves to the next item in the carousel, if there is one.
func next(animation : bool = true) -> void:
	go_to_index(_index + 1, animation)

## Enacts a manual drag on the carousel. This can be used even if [member can_drag] is [code]false[/code].
## Note that [param from] and [param dir] are considered in local coordinates.
## [br][br]
## Is not affected by [member hard_stop], [member drag_outside], and [member drag_limit].
func flick(from : Vector2, dir : Vector2) -> void:
	pass
## Returns if the carousel is currening scrolling via na animation
func is_animating() -> bool:
	return false
## Returns if the carousel is currening being dragged by player input.
func being_dragged() -> bool:
	return false

## Returns the current scroll delta.
func get_scroll(with_drag : bool = false) -> int:
	return posmod(_scroll_delta, _max_scroll)
#endregion


#region Subclasses
# Used to hold data about a carousel item
class ItemInfo:
	var node : Control
	var rect : Rect2
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
