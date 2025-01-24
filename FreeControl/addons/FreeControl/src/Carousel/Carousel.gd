@tool
class_name Carousel extends Container
## A container for Carousel Display of [Control] nodes.

## Changes the direction carousel items will be displayed in.
enum CAROUSEL_ORIENTATION {
	horizontal = 0b00, ## From Left to Right
	vertical = 0b01, ## From Top to Bottom
	horizontal_reversed = 0b10, ## From Right to Left
	vertical_reversed = 0b11, ## From Bottom to Top
	diagonal = 0b100,
	diagonal_reversed = 0b101,
	antidiagonal = 0b110,
	antidiagonal_reversed = 0b111,
}
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

## This signal is emited when a snap reaches it's destination.
signal snap_end
## This signal is emited when a snap begins.
signal snap_begin
## This signal is emited when a drag finishes. This does not include the slowdown caused when [memeber hard_stop] is [code]false[/code].
signal drag_end
## This signal is emited when a drag begins.
signal drag_begin
## This signal is emited when the slowdown, caused when [memeber hard_stop] is [code]false[/code], finished naturally.
signal slowdown_end
## This signal is emited when the slowdown, caused when [memeber hard_stop] is [code]false[/code], is interrupted by another drag or other feature. 
signal slowdown_interupted

@export_group("Carousel Options")
## The index of the item this carousel will start at.
@export var starting_index : int = 0:
	set(val):
		if is_node_ready() && _item_count != 0:
			val = posmod(val, _item_count)
		if starting_index != val:
			starting_index = val
			go_to_index(-val, false)
## The size of each item in the carousel.
@export var item_size : Vector2 = Vector2(200, 200):
	set(val):
		if item_size != val:
			var current_index := get_carousel_index()
			item_size = val
			_settup_children()
			go_to_index(current_index, false)
## The space between each item in the carousel.
@export var item_seperation : int = 0:
	set(val):
		if item_seperation != val:
			item_seperation = val
			_kill_animation()
			_adjust_children()
## The orientation the carousel items will be displayed in.
@export var orientation : CAROUSEL_ORIENTATION = CAROUSEL_ORIENTATION.horizontal:
	set(val):
		if orientation != val:
			var current_index := get_carousel_index()
			orientation = val
			_kill_animation()
			_adjust_children()
			go_to_index(current_index, false)

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
			_adjust_children()
			notify_property_list_changed()
## The number of items, surrounding the current item of the current index, that will be visible.
## If [code]-1[/code], all items will be visible.
@export var display_range : int = -1:
	set(val):
		val = max(-1, val)
		if val != display_range:
			display_range = val
			_adjust_children()

@export_group("Snap")
## Assigns the behavior of how draging scrolls the carousel items. Also see [member snap_carousel_transtion_type], [member snap_carousel_ease_type], and [member paging_requirement].
@export var snap_behavior : SNAP_BEHAVIOR = SNAP_BEHAVIOR.SNAP:
	set(val):
		if val != snap_behavior:
			snap_behavior = val
			if is_node_ready():
				_end_drag_slowdown()
				_create_animation(get_carousel_index(), ANIMATION_TYPE.SNAP)
			notify_property_list_changed()
## If [memeber snap_behavior] is [SNAP_BEHAVIOR.PAGING], this is the draging threshold needed to page to the next carousel item.
@export var paging_requirement : int = 200:
	set(val):
		val = max(1, val)
		if val != paging_requirement:
			paging_requirement = val
			_adjust_children()

@export_group("Animation Options")
@export_subgroup("Manual")
## The duration of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export_range(0.001, 2.0, 0.001, "or_greater") var manual_carousel_duration : float = 0.4
## The [enum Tween.TransitionType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_transtion_type : Tween.TransitionType
## The [enum Tween.EaseType] of the animation any call to [method go_to_index] will cause, if the animation option is requested. 
@export var manual_carousel_ease_type : Tween.EaseType

@export_subgroup("Snap")
## The duration of the animation when snapping to an item.
@export_range(0.001, 2.0, 0.001, "or_greater") var snap_carousel_duration : float = 0.2
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
			if !val:
				_drag_scroll_value = 0
				if _is_dragging:
					_adjust_children()
@export_subgroup("Limits")
## The max amount a user can drag in either direction. If [code]0[/code], then the user can drag any amount they wish.
@export var drag_limit : int = 0:
	set(val):
		val = max(0, val)
		if val != drag_limit: drag_limit = val
## When dragging, the user will not be able to move past the last or first item, besides for [member border_limit] number of extra pixels.
## [br][br]
## This value is assumed [code]false[/code] is [memeber display_loop] is [code]true[/code].
@export var enforce_border : bool = false:
	set(val):
		if val != enforce_border:
			enforce_border = val
			_adjust_children()
			notify_property_list_changed()
## The amount of extra pixels a user can drag past the last and before the first item in the carousel.
## [br][br]
## This property does nothing if enforce_border is [code]false[/code].
@export var border_limit : int = 0:
	set(val):
		if val != border_limit:
			border_limit = val
			_adjust_children()

@export_subgroup("Slowdown")
## If [code]true[/code] the carousel will immediately stop when not being dragged. Otherwise, drag speed will be gradually decreased.
## [br][br]
## This property is assumed [code]true[/code] if [member snap_behavior] is set to [SNAP_BEHAVIOR.PAGING]. Also see [member slowdown_drag], [member slowdown_friction], and [member slowdown_cutoff].
@export var hard_stop : bool = true:
	set(val):
		if val != hard_stop:
			hard_stop = val
			if is_node_ready():
				_end_drag_slowdown()
			notify_property_list_changed()
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

var _scroll_value : int
var _drag_scroll_value : int
var _drag_velocity : float

var _item_count : int = 0
var _item_infos : Array

var _scroll_tween : Tween
var _is_dragging : bool = false

var _last_animation : ANIMATION_TYPE = ANIMATION_TYPE.NONE


func _get_child_rect(child : Control) -> Rect2:
	var child_pos : Vector2 = (size - item_size) * 0.5
	var child_size : Vector2
	
	child_size = child.get_combined_minimum_size()
	match child.size_flags_horizontal:
		SIZE_FILL: child_size.x = item_size.x
		SIZE_SHRINK_BEGIN: pass
		SIZE_SHRINK_CENTER: child_pos.x += (item_size.x - child_size.x) * 0.5
		SIZE_SHRINK_END: child_pos.x += (item_size.x - child_size.x)
	match child.size_flags_vertical:
		SIZE_FILL: child_size.y = item_size.y
		SIZE_SHRINK_BEGIN: pass
		SIZE_SHRINK_CENTER: child_pos.y += (item_size.y - child_size.y) * 0.5
		SIZE_SHRINK_END: child_pos.y += (item_size.y - child_size.y)
	
	child.size = child_size
	child.position = child_pos
	
	return Rect2(child_pos, child_size)
func _get_children() -> Array[Control]:
	var ret : Array[Control]
	for child : Node in get_children():
		if child is Control:
			ret.append(child)
	return ret
func _get_relevant_axis() -> int:
	if bool(orientation & 0b100):
		return item_size.length()
	
	return (item_size.y if bool(orientation & 0b01) else item_size.x) + item_seperation
func _get_adjusted_scroll() -> int:
	var scroll := _scroll_value
	if snap_behavior != SNAP_BEHAVIOR.PAGING:
		scroll += _drag_scroll_value
	if enforce_border:
		scroll = clampi(scroll, -border_limit, _get_relevant_axis() * (_item_count - 1) + border_limit)
	elif display_loop:
		scroll = posmod(scroll, _get_relevant_axis() * _item_count)
	return scroll


func _create_animation(idx : int, animation_type : ANIMATION_TYPE) -> void:
	_kill_animation()
	if _item_count == 0: return
	_scroll_tween = create_tween()
	
	var axis := _get_relevant_axis()
	var max_scroll := axis * _item_count
	if max_scroll == 0: max_scroll = 1
	
	var desired_scroll := posmod(axis * idx, max_scroll)
	
	if allow_loop && display_loop:
		_scroll_value = posmod(_scroll_value, max_scroll)
		if abs(_scroll_value - desired_scroll) > (max_scroll >> 1):
			var left_distance := posmod(_scroll_value - desired_scroll, max_scroll)
			var right_distance := posmod(desired_scroll - _scroll_value, max_scroll)
		
			if left_distance < right_distance:
				desired_scroll -= max_scroll
			else:
				desired_scroll += max_scroll
	
	_last_animation = animation_type
	match animation_type:
		ANIMATION_TYPE.MANUAL:
			_scroll_tween.set_ease(manual_carousel_ease_type)
			_scroll_tween.set_trans(manual_carousel_transtion_type)
			_scroll_tween.tween_method(
				_animation_method,
				_scroll_value,
				desired_scroll,
				manual_carousel_duration)
		ANIMATION_TYPE.SNAP:
			snap_begin.emit()
			_scroll_tween.set_ease(snap_carousel_ease_type)
			_scroll_tween.set_trans(snap_carousel_transtion_type)
			_scroll_tween.tween_method(
				_animation_method,
				_scroll_value,
				desired_scroll,
				snap_carousel_duration)
			_scroll_tween.tween_callback(_kill_animation)
	_scroll_tween.play()
func _animation_method(scroll : int) -> void:
	_scroll_value = scroll
	_adjust_children()
func _kill_animation() -> void:
	if _last_animation == ANIMATION_TYPE.SNAP:
		snap_end.emit()
	_last_animation = ANIMATION_TYPE.NONE
	
	if _scroll_tween && _scroll_tween.is_running():
		_scroll_tween.kill()


func _sort_children() -> void:
	_settup_children()
	_adjust_children()
func _settup_children() -> void:
	var children : Array[Control] = _get_children()
	_item_count = children.size()
	
	_item_infos.resize(_item_count)
	for i : int in range(0, _item_count):
		var item_info := ItemInfo.new()
		item_info.node = children[i]
		item_info.rect = _get_child_rect(children[i])
		_item_infos[i] = item_info
func _adjust_children() -> void:
	if _item_count == 0: return
	
	var range : Array
	var children : Array[Control] = _get_children()
	var axis := _get_relevant_axis()
	var scroll := _get_adjusted_scroll()
	
	var index : int
	var local_scroll : int
	var adjustment : int
	
	if axis == 0:
		index = 0
		local_scroll = 0
		adjustment = 0
	else:
		index = int(scroll / axis)
		local_scroll = fposmod(scroll, axis)
		adjustment = int(scroll < 0)
	
	index += adjustment & int(local_scroll == 0)
	
	_on_progress(scroll)
	
	if display_loop:
		if display_range == -1:
			range = range(0, _item_count)
			for i : int in range:
				_item_infos[i].loaded = false
		else:
			range = range(0, (display_range << 1) + 1)
			for i : int in range(0, _item_count):
				var item_info : ItemInfo = _item_infos[i]
				item_info.loaded = false
				item_info.node.visible = false
		
		for item : int in range:
			var local_offset := (item >> 1) * (((item & 1) << 1) - 1) + (item & 1)
			var local_index := posmod(index + local_offset, _item_count)
			var item_info : ItemInfo = _item_infos[local_index]
			if item_info.loaded: break
			
			local_offset += adjustment
			var rect : Rect2 = item_info.rect
			match orientation:
				CAROUSEL_ORIENTATION.horizontal:
					rect.position.x += local_offset * axis - local_scroll
				CAROUSEL_ORIENTATION.vertical:
					rect.position.y += local_offset * axis - local_scroll
				CAROUSEL_ORIENTATION.horizontal_reversed:
					rect.position.x -= local_offset * axis - local_scroll
				CAROUSEL_ORIENTATION.vertical_reversed:
					rect.position.y -= local_offset * axis - local_scroll
				CAROUSEL_ORIENTATION.diagonal:
					var value := local_offset * axis - local_scroll
					rect.position.x += value
					rect.position.y += value
				CAROUSEL_ORIENTATION.diagonal_reversed:
					var value := -(local_offset * axis - local_scroll)
					rect.position.x += value
					rect.position.y += value
				CAROUSEL_ORIENTATION.antidiagonal:
					var value := local_offset * axis - local_scroll
					rect.position.x += value
					rect.position.y -= value
				CAROUSEL_ORIENTATION.antidiagonal_reversed:
					var value := local_offset * axis - local_scroll
					rect.position.x -= value
					rect.position.y += value
			
			fit_child_in_rect(item_info.node, rect)
			item_info.loaded = true
			item_info.node.visible = true
			item_info.node.z_index = index - abs(local_offset)
			_on_item_progress(item_info.node, local_scroll, scroll, item, local_index)
	else:
		if display_range == -1:
			range = range(0, _item_count)
		else:
			range = range(max(0, index - display_range), min(_item_count, index + display_range + 1))
			for info : ItemInfo in _item_infos:
				info.node.visible = false
		
		for item : int in range:
			var local_index := item - index
			var item_info : ItemInfo = _item_infos[item]
			
			local_index += adjustment
			var rect : Rect2 = item_info.rect
			match orientation:
				CAROUSEL_ORIENTATION.horizontal:
					rect.position.x += local_index * axis - local_scroll
				CAROUSEL_ORIENTATION.vertical:
					rect.position.y += local_index * axis - local_scroll
				CAROUSEL_ORIENTATION.horizontal_reversed:
					rect.position.x -= local_index * axis - local_scroll
				CAROUSEL_ORIENTATION.vertical_reversed:
					rect.position.y -= local_index * axis - local_scroll
				CAROUSEL_ORIENTATION.diagonal:
					var value := local_index * axis - local_scroll
					rect.position.x += value
					rect.position.y += value
				CAROUSEL_ORIENTATION.diagonal_reversed:
					var value := -(local_index * axis - local_scroll)
					rect.position.x += value
					rect.position.y += value
				CAROUSEL_ORIENTATION.antidiagonal:
					var value := local_index * axis - local_scroll
					rect.position.x += value
					rect.position.y -= value
				CAROUSEL_ORIENTATION.antidiagonal_reversed:
					var value := local_index * axis - local_scroll
					rect.position.x -= value
					rect.position.y += value
			
			fit_child_in_rect(item_info.node, rect)
			item_info.node.visible = true
			item_info.node.z_index = index - abs(local_index)
			_on_item_progress(item_info.node, local_scroll, scroll, item, local_index)


func _start_drag_slowdown() -> void:
	if get_tree() && !get_tree().process_frame.is_connected(_handle_drag_slowdown):
		get_tree().process_frame.connect(_handle_drag_slowdown)
func _end_drag_slowdown() -> void:
	if abs(_drag_velocity) < slowdown_cutoff:
		slowdown_interupted.emit()
		_drag_velocity = 0
		if snap_behavior == SNAP_BEHAVIOR.SNAP:
			_create_animation(get_carousel_index(), ANIMATION_TYPE.SNAP)
	if get_tree() && get_tree().process_frame.is_connected(_handle_drag_slowdown):
		get_tree().process_frame.disconnect(_handle_drag_slowdown)
func _handle_drag_slowdown() -> void:
	if abs(_drag_velocity) < slowdown_cutoff:
		slowdown_end.emit()
		_end_drag_slowdown()
		return
	
	if _drag_velocity > 0:
		_drag_velocity = max(0, _drag_velocity - slowdown_friction)
	else:
		_drag_velocity = min(0, _drag_velocity + slowdown_friction)
	_drag_velocity *= slowdown_drag
	_scroll_value += _drag_velocity
	_adjust_children()


func _ready() -> void:
	if !sort_children.is_connected(_sort_children):
		sort_children.connect(_sort_children)
	if !tree_exiting.is_connected(_end_drag_slowdown):
		tree_exiting.connect(_end_drag_slowdown)
	
	_settup_children()
	if _item_count > 0:
		starting_index = posmod(starting_index, _item_count)
		go_to_index(-starting_index, false)
func _gui_input(event: InputEvent) -> void:
	if !can_drag: return
	
	if event is InputEventMouseMotion:
		pass
	
	if event is InputEventScreenDrag && event.index == 0:
		if !_is_dragging:
			drag_begin.emit()
			_end_drag_slowdown()
			_kill_animation()
		_is_dragging = true
		
		match orientation:
			CAROUSEL_ORIENTATION.horizontal:
				_drag_scroll_value -= event.relative.x
				_drag_velocity = -event.relative.x
			CAROUSEL_ORIENTATION.vertical:
				_drag_scroll_value -= event.relative.y
				_drag_velocity = -event.relative.y
			CAROUSEL_ORIENTATION.horizontal_reversed:
				_drag_scroll_value += event.relative.x
				_drag_velocity = event.relative.x
			CAROUSEL_ORIENTATION.vertical_reversed:
				_drag_scroll_value += event.relative.y
				_drag_velocity = event.relative.y
			CAROUSEL_ORIENTATION.diagonal:
				var value : float = event.relative.length()
				if event.relative.x > -event.relative.y:
					value = -value
				_drag_scroll_value += value
				_drag_velocity = value
			CAROUSEL_ORIENTATION.diagonal_reversed:
				var value : float = event.relative.length()
				if event.relative.x < -event.relative.y:
					value = -value
				_drag_scroll_value += value
				_drag_velocity = value
			CAROUSEL_ORIENTATION.antidiagonal:
				var value : float = event.relative.length()
				if event.relative.max_axis_index() == Vector2.AXIS_X:
					value = -value
				_drag_scroll_value += value
				_drag_velocity = value
			CAROUSEL_ORIENTATION.antidiagonal_reversed:
				var value : float = event.relative.length()
				if event.relative.max_axis_index() == Vector2.AXIS_Y:
					value = -value
				_drag_scroll_value += value
				_drag_velocity = value
		
		if drag_limit != 0:
			_drag_scroll_value = clampi(_drag_scroll_value, -drag_limit, drag_limit)
		
		if snap_behavior == SNAP_BEHAVIOR.PAGING:
			if paging_requirement < _drag_scroll_value:
				_drag_scroll_value = 0
				var desired := get_carousel_index() + 1
				if allow_loop || desired < _item_count:
					_create_animation(desired, ANIMATION_TYPE.SNAP)
			elif -paging_requirement > _drag_scroll_value:
				_drag_scroll_value = 0
				var desired := get_carousel_index() - 1
				if allow_loop || desired >= 0:
					_create_animation(desired, ANIMATION_TYPE.SNAP)
		else:
			_adjust_children()
	elif event is InputEventScreenTouch && !event.pressed:
		_is_dragging = false
		drag_end.emit()
		
		if snap_behavior != SNAP_BEHAVIOR.PAGING:
			_scroll_value = _get_adjusted_scroll()
			_drag_scroll_value = 0
			if snap_behavior == SNAP_BEHAVIOR.NONE:
				if !hard_stop: _start_drag_slowdown()
			elif snap_behavior == SNAP_BEHAVIOR.SNAP:
				if hard_stop: _create_animation(get_carousel_index(), ANIMATION_TYPE.SNAP)
				else: _start_drag_slowdown()
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
func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]



# Public Functions

## Gets the index of the current carousel item.[br]
## If [param with_drag] is [code]true[/code] the current drag will also be considered.[br]
## If [param with_clamp] is [code]true[/code] the index will be looped if [member allow_loop] is true or clamped to a vaild index within the carousel.
func get_carousel_index(with_drag : bool = false, with_clamp : bool = true) -> int:
	if _item_count == 0: return -1
	
	var scroll : int = _scroll_value
	if with_drag: scroll += _drag_scroll_value
	
	var calculated := floori((float(scroll) / float(_get_relevant_axis())) + 0.5)
	if with_clamp:
		if allow_loop:
			calculated = posmod(calculated, _item_count)
		else:
			calculated = clampi(calculated, 0, _item_count - 1)
	
	return calculated
## Moves to an item of the given index within the carousel. If an invalid index is given, it will be posmod into a vaild index.
func go_to_index(idx : int, animation : bool = true) -> void:
	if _item_count == 0: return
	
	if allow_loop:
		idx = posmod(idx, _item_count)
	else:
		idx = clamp(idx, 0, _item_count - 1)
	
	if animation: _create_animation(idx, ANIMATION_TYPE.MANUAL)
	else:
		_kill_animation()
		_scroll_value = -_get_relevant_axis() * idx
		_adjust_children()
## Moves to the previous item in the carousel, if there is one.
func prev(animation : bool = true) -> void:
	go_to_index(get_carousel_index() - 1, animation)
## Moves to the next item in the carousel, if there is one.
func next(animation : bool = true) -> void:
	go_to_index(get_carousel_index() + 1, animation)
## Returns if the carousel is currening scrolling via na animation
func is_animating() -> bool:
	return _scroll_tween.is_running()
## Returns if the carousel is currening being dragged by player input.
func being_dragged() -> bool:
	return _is_dragging
## Returns the current scroll value.
func get_scroll(with_drag : bool = false) -> int:
	if with_drag:
		return _scroll_value + _drag_scroll_value
	return _scroll_value
## Returns the current number of items in the carousel
func get_item_count() -> int:
	return _item_count


# Virtual Functions

## A virtual function that is is called whenever the scroll changes.
func _on_progress(scroll : int) -> void: pass
## A virtual function that is is called whenever the scroll changes, for each visible item in the carousel
func _on_item_progress(item : Control, local_scroll : int, scroll : int, local_index : int, index : int) -> void: pass


 
# Used to hold data about a carousel item
class ItemInfo:
	var node : Control
	var rect : Rect2
	var loaded : bool
