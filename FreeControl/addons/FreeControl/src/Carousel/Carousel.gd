@tool
class_name Carousel extends Container

enum DRAG_LIMIT {
	None = 0b00,
	Limits = 0b01,
	Item = 0b10,
	Both = 0b11
}
enum CAROUSEL_ORIENTATION {
	horizontal = 0b00,
	vertical = 0b01,
	horizontal_reversed = 0b10,
	vertical_reversed = 0b11
}
enum SNAP_BEHAVIOR {
	NONE = 0b00,
	SNAP = 0b01,
	PAGING = 0b10
}
enum ANIMATION_TYPE {
	NONE = 0b00,
	MANUAL = 0b01,
	SNAP = 0b10
}

signal snap_end
signal snap_begin

signal drag_end
signal drag_begin

@export_group("Carousel Options")
@export var starting_index : int = 0:
	set(val):
		if is_node_ready() && _item_count != 0:
			val = posmod(val, _item_count)
		if starting_index != val:
			starting_index = val
			go_to_index(-val, false)
@export var item_size : Vector2 = Vector2(200, 200):
	set(val):
		if item_size != val:
			var current_index := get_carousel_index()
			item_size = val
			_settup_children()
			go_to_index(current_index, false)
@export var item_seperation : int = 0:
	set(val):
		if item_seperation != val:
			item_seperation = val
			_kill_animation()
			_adjust_children()
@export var orientation : CAROUSEL_ORIENTATION = CAROUSEL_ORIENTATION.horizontal:
	set(val):
		if orientation != val:
			var current_index := get_carousel_index()
			orientation = val
			_kill_animation()
			_adjust_children()
			go_to_index(current_index, false)

@export_group("Loop Options")
@export var allow_loop : bool = true
@export var display_loop : bool = true:
	set(val):
		if val != display_loop:
			display_loop = val
			_adjust_children()
			notify_property_list_changed()
@export var display_range : int = -1:
	set(val):
		val = max(-1, val)
		if val != display_range:
			display_range = val
			_adjust_children()

@export_group("Snap")
@export var snap_behavior : SNAP_BEHAVIOR = SNAP_BEHAVIOR.SNAP:
	set(val):
		if val != snap_behavior:
			snap_behavior = val
			notify_property_list_changed()
			if val && is_node_ready():
				_create_animation(get_carousel_index(), ANIMATION_TYPE.SNAP)
@export var paging_requirement : int = 200:
	set(val):
		val = max(1, val)
		if val != paging_requirement:
			paging_requirement = val
			_adjust_children()

@export_group("Animation Options")
@export_subgroup("Manual")
@export_range(0.001, 2.0, 0.001, "or_greater") var manual_carousel_duration : float = 0.4
@export var manual_carousel_transtion_type : Tween.TransitionType
@export var manual_carousel_ease_type : Tween.EaseType

@export_subgroup("Snap")
@export_range(0.001, 2.0, 0.001, "or_greater") var snap_carousel_duration : float = 0.2
@export var snap_carousel_transtion_type : Tween.TransitionType
@export var snap_carousel_ease_type : Tween.EaseType

@export_group("Drag")
@export var can_drag : bool = true:
	set(val):
		if val != can_drag:
			can_drag = val
			if !val:
				_drag_scroll_value = 0
				if _is_dragging:
					_adjust_children()
@export var enforce_border : bool = false:
	set(val):
		if val != enforce_border:
			enforce_border = val
			_adjust_children()
			notify_property_list_changed()
@export var drag_limit : int = 0:
	set(val):
		val = max(0, val)
		if val != drag_limit: drag_limit = val
@export var border_limit : int = 0:
	set(val):
		if val != border_limit:
			border_limit = val
			_adjust_children()

var _scroll_value : int
var _drag_scroll_value : int

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
	return (item_size.y if bool(orientation & 0b01) else item_size.x) + item_seperation
func _get_adjusted_scroll() -> int:
	var scroll := _scroll_value
	if snap_behavior != SNAP_BEHAVIOR.PAGING:
		scroll += _drag_scroll_value
	if enforce_border:
		scroll = clampi(scroll, -border_limit, _get_relevant_axis() * (_item_count - 1) + border_limit)
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
			_scroll_tween.tween_method(
				_animation_method,
				_scroll_value,
				desired_scroll,
				manual_carousel_duration)
			_scroll_tween.set_ease(manual_carousel_ease_type)
			_scroll_tween.set_trans(manual_carousel_transtion_type)
		ANIMATION_TYPE.SNAP:
			snap_begin.emit()
			_scroll_tween.tween_method(
				_animation_method,
				_scroll_value,
				desired_scroll,
				snap_carousel_duration)
			_scroll_tween.set_ease(snap_carousel_ease_type)
			_scroll_tween.set_trans(snap_carousel_transtion_type)
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
			
			fit_child_in_rect(item_info.node, rect)
			item_info.loaded = true
			item_info.node.visible = true
			item_info.node.z_index = index - abs(local_offset)
			_on_item_progress(item_info.node, local_scroll, scroll, local_index, item)
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
			
			fit_child_in_rect(item_info.node, rect)
			item_info.node.visible = true
			item_info.node.z_index = index - abs(local_index)
			_on_item_progress(item_info.node, local_scroll, scroll, local_index, item)


func _ready() -> void:
	if !sort_children.is_connected(_sort_children):
		sort_children.connect(_sort_children)
	_settup_children()
	starting_index = posmod(starting_index, _item_count)
	go_to_index(-starting_index, false)
func _gui_input(event: InputEvent) -> void:
	if !can_drag: return
	
	if event is InputEventScreenDrag && event.index == 0:
		if !_is_dragging:
			drag_begin.emit()
			_kill_animation()
		_is_dragging = true
		
		match orientation:
			CAROUSEL_ORIENTATION.horizontal:
				_drag_scroll_value -= event.relative.x
			CAROUSEL_ORIENTATION.vertical:
				_drag_scroll_value -= event.relative.y
			CAROUSEL_ORIENTATION.horizontal_reversed:
				_drag_scroll_value += event.relative.x
			CAROUSEL_ORIENTATION.vertical_reversed:
				_drag_scroll_value += event.relative.y
		
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
		if snap_behavior != SNAP_BEHAVIOR.PAGING:
			_scroll_value = _get_adjusted_scroll()
		_drag_scroll_value = 0
		_is_dragging = false
		drag_end.emit()
		
		if snap_behavior == SNAP_BEHAVIOR.SNAP:
			_create_animation(get_carousel_index(), ANIMATION_TYPE.SNAP)
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


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]



# Public Functions

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
func go_to_index(idx : int, animation : bool = true) -> void:
	if animation: _create_animation(idx, ANIMATION_TYPE.MANUAL)
	else:
		_kill_animation()
		_scroll_value = -_get_relevant_axis() * idx
		_adjust_children()
func prev(animation : bool = true) -> void:
	go_to_index(get_carousel_index() - 1, animation)
func next(animation : bool = true) -> void:
	go_to_index(get_carousel_index() + 1, animation)



# Virtual Functions

func _on_progress(scroll : int) -> void: pass
func _on_item_progress(item : Control, local_scroll : int, scroll : int, local_index : int, index : int) -> void: pass



class ItemInfo:
	var node : Control
	var rect : Rect2
	var loaded : bool
