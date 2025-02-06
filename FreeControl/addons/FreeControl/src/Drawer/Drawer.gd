@tool
class_name Drawer extends Container
## A [Container] node used for easy UI Drawers.

## A flag enum used to classify which input type is allowed.
enum ActionMode {
	ACTION_MODE_BUTTON_NONE = 0, ## Allows no input
	ACTION_MODE_BUTTON_PRESS = 1, ## Toggles the drawer on tap/click press
	ACTION_MODE_BUTTON_RELEASE = 2, ## Toggles the drawer on tap/click release
	ACTION_MODE_BUTTON_DRAG = 4, ## Allows user to drag the drawer
}

## An enum used to classify where input is accepted.
enum InputAreaMode {
	Anywhere = 0, ## Input accepted anywere on the screen.
	WithinBounds = 1, ## Input is accepted only within this node's rect.
	ExcludeDrawer = 2, ## Input is accepted anywhere except on the drawer's rect.
	WithinEmptyBounds = 3 ## Input is accepted only within this node's rect, outside of the drawer's rect.
}

## An enum used to classify when dragging is allowed.
enum DragMode {
	NEVER = 0, ## No dragging allowed.
	ON_OPEN = 1, ## Dragging is allowed to open the drawer.
	ON_CLOSE = 2, ## Dragging is allowed to close the drawer.
	ON_OPEN_OR_CLOSE = 0b11 ## Dragging is allowed to open or close the drawer.
}


## Emited when drawer is begining an opening/closing animation, if caused manually.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal toggle_start(toggle : bool)
## Emited when drawer is ending an opening/closing animation, if caused manually.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal toggle_end(toggle : bool)
## Emited when drag has began.
## [br][br]
## Also see: [member allow_drag].
signal drag_start
## Emited when drag has ended.
## [br][br]
## Also see: [member allow_drag].
signal drag_end



var _state : bool
## The state of the drawer. If [code]true[/code], the drawer is open. Otherwise closed.
## [br][br]
## Also see: [method toggle_drawer].
var state : bool:
	get: return _state
	set(val):
		if _state != val:
			_state = val
			toggle_drawer(_state)

#@export_group("Drawer Angle")
## The angle in which the drawer will open/close from.
## [br][br]
## Also see: [member drawer_angle_axis_snap].
var drawer_angle : float = 0.0:
	set(val):
		if drawer_angle != val:
			drawer_angle = val
			_angle_vec = Vector2.RIGHT.rotated(deg_to_rad(drawer_angle))
			
			_kill_animation()
			_find_offsets()
			_current_progress = _max_offset * float(_state)
			_adjust_children()
## If [code]true[/code], the drawer will be snapped to move as strictly cardinally as possible.
## [br][br]
## Also see: [member drawer_angle].
var drawer_angle_axis_snap : bool:
	set(val):
		if drawer_angle_axis_snap != val:
			drawer_angle_axis_snap = val
			
			_kill_animation()
			_find_offsets()
			_current_progress = _max_offset * float(_state)
			_adjust_children()

#@export_group("Drawer Span")
## If [code]false[/code], [member drawer_width] is equal to a ratio of this node's [Control.size]'s x component.
## [br]. Else, [member drawer_width] is directly editable.
var drawer_width_by_pixel : bool:
	set(val):
		if val != drawer_width_by_pixel:
			drawer_width_by_pixel = val
			if val:
				drawer_width *= size.x
			else:
				if size.x == 0:
					drawer_width = 0
				else:
					drawer_width /= size.x
			
			notify_property_list_changed()
## The width of the drawer. 
## [br][br]
## Also see: [member drawer_width_by_pixel].
var drawer_width : float = 1:
	set(val):
		if val != drawer_width:
			drawer_width = val
			_calculate_childrend()
## If [code]false[/code], [member drawer_height] is equal to a ratio of this node's [Control.size]'s y component.
## [br]. Else, [member drawer_height] is directly editable.
var drawer_height_by_pixel : bool:
	set(val):
		if val != drawer_height_by_pixel:
			drawer_height_by_pixel = val
			if val:
				drawer_height *= size.y
			else:
				if size.y == 0:
					drawer_height = 0
				else:
					drawer_height /= size.y
			
			notify_property_list_changed()
## The height of the drawer. 
## [br][br]
## Also see: [member drawer_height_by_pixel].
var drawer_height : float = 1:
	set(val):
		if val != drawer_height:
			drawer_height = val
			_calculate_childrend()

#@export_group("Input Options")
## A flag enum used to classify which input type is allowed.
var action_mode : ActionMode = ActionMode.ACTION_MODE_BUTTON_PRESS:
	set(val):
		if val != action_mode:
			action_mode = val
			_is_dragging = false

#@export_subgroup("Margins")
## Extra pixels to where the open drawer lies when open.
var open_margin : int = 0:
	set(val):
		if val != open_margin:
			open_margin = val
			_calculate_childrend()
## Extra pixels to where the open drawer lies when closed.
var close_margin : int = 0:
	set(val):
		if val != close_margin:
			close_margin = val
			_calculate_childrend()

#@export_subgroup("Drag Options")
## Permissions on how the user may drag to open/close the drawer.
## [br][br]
## Also see: [member allow_drag], [member smooth_drag].
var allow_drag : DragMode = DragMode.ON_OPEN_OR_CLOSE
## If [code]true[/code], the drawer will react while the user drags.
var smooth_drag : bool = true
## The amount of extra the user is allowed to drag (in the open direction) before being stopped.
var drag_give : int = 0

#@export_subgroup("Open Input")
## A node to determine where vaild input, when closed, may start at.
## [br][br]
## Also see: [member allow_drag].
var open_bounds : InputAreaMode = InputAreaMode.WithinEmptyBounds
## The minimum amount you need to drag before your drag is considered to have closed the drawer.
## [br][br]
## Also see: [member allow_drag].
var open_drag_threshold : int = 50:
	set(val):
		val = max(0, val)
		if val != open_drag_threshold:
			open_drag_threshold = val

#@export_subgroup("Close Input")
## A node to determine where vaild input, when open, may start at.
## [br][br]
## Also see: [member allow_drag].
var close_bounds : InputAreaMode = InputAreaMode.WithinEmptyBounds
## The minimum amount you need to drag before your drag is considered to have opened the drawer.
## [br][br]
## Also see: [member allow_drag].
var close_drag_threshold : int = 200:
	set(val):
		val = max(0, val)
		if val != close_drag_threshold:
			close_drag_threshold = val

#@export_group("Animation")
#@export_subgroup("Manual Animation")
## The [enum Tween.TransitionType] used when manually opening and closing drawer.
## [br][br]
## Also see: [member state], [method toggle_drawer].
var manual_drawer_translate : Tween.TransitionType
## The [enum Tween.EaseType] used when manually opening and closing drawer.
## [br][br]
## Also see: [member state], [method toggle_drawer].
var manual_drawer_ease : Tween.EaseType
## The animation duration used when manually opening and closing drawer.
## [br][br]
## Also see: [member state], [method toggle_drawer].
var manual_drawer_duration : float = 0.2

#@export_subgroup("Drag Animation")
## The [enum Tween.TransitionType] used when snapping after a drag.
var drag_drawer_translate : Tween.TransitionType
## The [enum Tween.EaseType] used when snapping after a drag.
var drag_drawer_ease : Tween.EaseType
## The animation duration used when snapping after a drag.
var drag_drawer_duration : float = 0.2



var _min_size : Vector2
var _angle_vec : Vector2

var _animation_tween : Tween
var _current_progress : float
var _drag_value : float
var _is_dragging : bool

var _single_input : bool

var _inner_offset : Vector2
var _outer_offset : Vector2
var _max_offset : float


## Returns if the drawer is currently open.
func is_open() -> bool:
	return _state
## Returns if the drawer is currently animating.
func is_animating() -> bool:
	return _animation_tween && _animation_tween.is_running()
## Returns the size of the drawer.
func get_drawer_size() -> Vector2:
	var ret := Vector2(drawer_width, drawer_height)
	if !drawer_width_by_pixel:
		ret.x *= size.x
	if !drawer_height_by_pixel:
		ret.y *= size.y
	return ret.max(_min_size)
## Returns the offsert the drawer has, compared to this node's local position.
func get_drawer_offset(with_drag : bool = false) -> Vector2:
	return _get_drawer_offset(_inner_offset, _outer_offset, with_drag)
## Returns the rect the drawer has, compared to this node's local position.
func get_drawer_rect(with_drag : bool = false) -> Rect2:
	return Rect2(get_drawer_offset(with_drag), get_drawer_size())

## Gets the current progress the drawer is in animations. 
## Returns the value in pixel distance.
func get_progress(include_drag : bool = false, with_clamp : bool = true) -> float:
	var ret : float = _current_progress
	if include_drag:
		ret += _drag_value
	if with_clamp:
		ret = clampf(ret, -drag_give, _max_offset)
	return ret
## Gets the percentage of the drawer's current position between being closed and opened. 
## [code]0.0[/code] when closed and [code]1.0[/code] when opened.
func get_progress_adjusted(include_drag : bool = false, with_clamp : bool = true) -> float:
	return get_progress(include_drag, with_clamp) / _max_offset



func _get_relevant_axis() -> float:
	var drawer_size := get_drawer_size()
	var abs_angle_vec = _angle_vec.abs()
	
	if abs_angle_vec.y >= abs_angle_vec.x:
		return (drawer_size.x / abs_angle_vec.y)
	return (drawer_size.y / abs_angle_vec.x)
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control && child.visible))
	return ret
func _calculate_childrend() -> void:
	_find_offsets()
	_adjust_children()
func _adjust_children() -> void:
	var rect := get_drawer_rect(true)
	for child : Control in _get_control_children():
		fit_child_in_rect(child, rect)



func _find_minimum_size() -> Vector2:
	var min_size : Vector2 = Vector2.ZERO
	for child : Control in _get_control_children():
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size
func _find_offsets() -> void:
	var drawer_size := get_drawer_size()
	
	var distances_to_intersection_point := (size / _angle_vec).abs()
	var inner_distance := minf(distances_to_intersection_point.x, distances_to_intersection_point.y)
	var inner_point : Vector2 = (inner_distance * _angle_vec + (size - drawer_size)) * 0.5
	_inner_offset = inner_point.maxf(0).min(size - drawer_size)
	
	if drawer_angle_axis_snap:
		var half_drawer_size := drawer_size * 0.5
		var inner_point_half := inner_point + half_drawer_size
		_outer_offset = inner_point
		
		if abs(inner_point_half.x - size.x) < 0.01:
			_outer_offset.x += half_drawer_size.x
		elif abs(inner_point_half.x) < 0.01:
			_outer_offset.x -= half_drawer_size.x
		
		if abs(inner_point_half.y - size.y) < 0.01:
			_outer_offset.y += half_drawer_size.y
		elif abs(inner_point_half.y) < 0.01:
			_outer_offset.y -= half_drawer_size.y
	else:
		var distances_to_outer_center := ((size + drawer_size) / _angle_vec).abs()
		var outer_distance := minf(distances_to_outer_center.x, distances_to_outer_center.y)
		_outer_offset = (outer_distance * _angle_vec + (size - drawer_size)) * 0.5
	
	_max_offset = (_outer_offset - _inner_offset).length()
	_inner_offset += _angle_vec * open_margin
	_outer_offset -= _angle_vec * close_margin



## Allows opening and closing the drawer.
## [br][br]
## Also see: [member state].
func toggle_drawer(open : bool) -> void:
	toggle_start.emit(open)
	_toggle_drawer(open)
	_animation_tween.tween_callback(toggle_end.emit.bind(open))
func _toggle_drawer(open : bool, drag_animate : bool = false, use_drag_scroll : bool = false) -> void:
	_state = open
	_animate_to_progress(float(open), drag_animate, use_drag_scroll)
func _animate_to_progress(
			to_progress : float,
			drag_animate : bool = false,
			use_drag_scroll : bool = false
		) -> void:
	_kill_animation()
	_animation_tween = create_tween()
	
	if drag_animate:
		_animation_tween.set_trans(drag_drawer_translate)
		_animation_tween.set_ease(drag_drawer_ease)
		_animation_tween.tween_method(
			_animation_method,
			get_progress(use_drag_scroll),
			to_progress * _max_offset,
			drag_drawer_duration
		)
	else:
		_animation_tween.set_trans(manual_drawer_translate)
		_animation_tween.set_ease(manual_drawer_ease)
		_animation_tween.tween_method(
			_animation_method,
			get_progress(use_drag_scroll),
			to_progress * _max_offset,
			manual_drawer_duration
		)
func _kill_animation() -> void:
	if _animation_tween && _animation_tween.is_running():
		_animation_tween.kill()
func _animation_method(process : float) -> void:
	_current_progress = process
	_progress_changed(get_progress_adjusted())
	_adjust_children()



func _ready() -> void:
	sort_children.connect(_adjust_children)
	
	_angle_vec = Vector2.RIGHT.rotated(deg_to_rad(drawer_angle))
	call_deferred("_calculate_childrend")
func _get_minimum_size() -> Vector2:
	_min_size = _find_minimum_size()
	return _min_size
func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	
	ret.append({
		"name": "state",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	
	ret.append({
		"name": "Drawer Angle",
		"type": TYPE_NIL,
		"hint_string": "drawer_",
		"usage": PROPERTY_USAGE_GROUP
	})
	ret.append({
		"name": "drawer_angle",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 360, 0.001, or_less, or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drawer_angle_axis_snap",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	
	ret.append({
		"name": "Drawer Span",
		"type": TYPE_NIL,
		"hint_string": "drawer_",
		"usage": PROPERTY_USAGE_GROUP
	})
	ret.append({
		"name": "drawer_width_by_pixel",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drawer_width",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT
	}.merged({} if drawer_width_by_pixel else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_less, or_greater",
	}))
	ret.append({
		"name": "drawer_height_by_pixel",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drawer_height",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT
	}.merged({} if drawer_height_by_pixel else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_less, or_greater",
	}))
	
	ret.append({
		"name": "Input Options",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP
	})
	
	ret.append({
		"name": "action_mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": "Press Action:1,Release Action:2,Drag Action:4",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Margins",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "open_margin",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "close_margin",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Drag Options",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "allow_drag",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(DragMode.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "smooth_drag",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drag_give",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Open Input",
		"type": TYPE_NIL,
		"hint_string": "",
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "open_bounds",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(InputAreaMode.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "open_drag_threshold",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Close Input",
		"type": TYPE_NIL,
		"hint_string": "",
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "close_bounds",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(InputAreaMode.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "close_drag_threshold",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	
	ret.append({
		"name": "Animation",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP
	})
	
	ret.append({
		"name": "Manual Animation",
		"type": TYPE_NIL,
		"hint_string": "manual_drawer_",
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "manual_drawer_translate",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "TransitionType"),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "manual_drawer_ease",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "EaseType"),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "manual_drawer_duration",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Drag Animation",
		"type": TYPE_NIL,
		"hint_string": "drag_drawer_",
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "drag_drawer_translate",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "TransitionType"),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drag_drawer_ease",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "EaseType"),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drag_drawer_duration",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	return ret
func _property_can_revert(property: StringName) -> bool:
	match property:
		"state":
			return _state
		
		"drawer_angle":
			return drawer_angle
		"drawer_angle_axis_snap":
			return drawer_angle_axis_snap
		
		"drawer_width_by_pixel":
			return drawer_width_by_pixel
		"drawer_width":
			return drawer_width != (size.x if drawer_width_by_pixel else 1.0)
		"drawer_height_by_pixel":
			return drawer_height_by_pixel
		"drawer_height":
			return drawer_height != (size.y if drawer_height_by_pixel else 1.0)
		
		"action_mode":
			return action_mode != ActionMode.ACTION_MODE_BUTTON_PRESS
		
		"drag_give":
			return drag_give
		"open_margin":
			return open_margin
		"close_margin":
			return close_margin
		
		"allow_drag":
			return allow_drag != DragMode.ON_OPEN_OR_CLOSE
		"smooth_drag":
			return !smooth_drag
		
		"open_bounds":
			return open_bounds != InputAreaMode.WithinEmptyBounds
		"open_drag_threshold":
			return open_drag_threshold != 50
		
		"close_bounds":
			return close_bounds != InputAreaMode.WithinEmptyBounds
		"close_drag_threshold":
			return close_drag_threshold != 200
		
		"manual_drawer_translate":
			return manual_drawer_translate != Tween.TransitionType.TRANS_LINEAR
		"manual_drawer_ease":
			return manual_drawer_ease != Tween.EaseType.EASE_IN
		"manual_drawer_duration":
			return manual_drawer_duration != 0.2
		
		"drag_drawer_translate":
			return manual_drawer_translate  != Tween.TransitionType.TRANS_LINEAR
		"drag_drawer_ease":
			return manual_drawer_ease != Tween.EaseType.EASE_IN
		"drag_drawer_duration":
			return manual_drawer_duration != 0.2
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		"state", "smooth_drag", "drawer_width_by_pixel", "drawer_height_by_pixel":
			return false
		
		"drawer_angle", "drawer_angle_axis_snap", "drag_give", "open_margin", "close_margin":
			return 0
		"manual_drawer_duration", "drag_drawer_duration":
			return 0.2
		"open_drag_threshold":
			return 50
		"close_drag_threshold":
			return 200
		
		"drawer_width":
			return size.x if drawer_width_by_pixel else 1.0
		"drawer_height":
			return size.y if drawer_height_by_pixel else 1.0
		
		"action_mode":
			return ActionMode.ACTION_MODE_BUTTON_PRESS
		"allow_drag":
			return DragMode.ON_OPEN_OR_CLOSE
		"open_bounds":
			return InputAreaMode.WithinEmptyBounds
		"close_bounds":
			return InputAreaMode.WithinEmptyBounds
		
		"manual_drawer_translate", "drag_drawer_translate":
			return Tween.TransitionType.TRANS_LINEAR
		"manual_drawer_ease", "drag_drawer_ease":
			return Tween.EaseType.EASE_IN
	return null
func _get_enum_string(className : StringName, enumName : StringName) -> String:
	var ret : String
	for constant_name in ClassDB.class_get_enum_constants(className, enumName):
		var constant_value: int = ClassDB.class_get_integer_constant(className, constant_name)
		ret += "%s:%d, " % [constant_name, constant_value]
	return ret.left(-2).replace("_", " ").capitalize().replace(", ", ",")
func _convert_to_enum(strs : PackedStringArray) -> String:
	return ", ".join(strs).replace("_", " ").capitalize().replace(", ", ",")



func _handle_touch(event : InputEvent) -> void:
	if _single_input: return
	_single_input = true
	set_deferred("_single_input", false)
	state = !_state
func _confirm_input_accept(event : InputEvent) -> bool:
	if mouse_filter == MouseFilter.MOUSE_FILTER_IGNORE: return false
	
	var boundType : InputAreaMode
	if _state:
		boundType = close_bounds
		if !(allow_drag & DragMode.ON_CLOSE):
			return false
	else:
		boundType = open_bounds
		if !(allow_drag & DragMode.ON_OPEN):
			return false
	
	match boundType:
		InputAreaMode.Anywhere:
			pass
		InputAreaMode.WithinBounds:
			if !get_rect().has_point(event.position):
				return false
		InputAreaMode.ExcludeDrawer:
			if get_drawer_rect().has_point(event.position):
				return false
		InputAreaMode.WithinEmptyBounds:
			if get_rect().intersection(get_drawer_rect()).has_point(event.position):
				return false
	
	if mouse_filter == MouseFilter.MOUSE_FILTER_STOP: accept_event()
	return true
func _input(event: InputEvent) -> void:
	if action_mode & (ActionMode.ACTION_MODE_BUTTON_PRESS | ActionMode.ACTION_MODE_BUTTON_RELEASE):
		if event is InputEventMouseButton || event is InputEventScreenTouch:
			if !_confirm_input_accept(event): return
			if event.pressed:
				if action_mode & ActionMode.ACTION_MODE_BUTTON_PRESS:
					_toggle_drawer(!_state)
			else:
				if action_mode & ActionMode.ACTION_MODE_BUTTON_RELEASE:
					_toggle_drawer(!_state)
	if action_mode & ActionMode.ACTION_MODE_BUTTON_DRAG:
		if event is InputEventMouseMotion || event is InputEventScreenDrag:
			if event.pressure == 0:
				if _drag_value:
					drag_end.emit()
					if _state:
						if _drag_value < -open_drag_threshold:
							_toggle_drawer(false, true, smooth_drag)
						else:
							_toggle_drawer(true, true, smooth_drag)
					else:
						if _drag_value > close_drag_threshold:
							_toggle_drawer(true, true, smooth_drag)
						else:
							_toggle_drawer(false, true, smooth_drag)
				_is_dragging = false
				_drag_value = 0.0
			else:
				if !_is_dragging:
					if !_confirm_input_accept(event): return
					drag_start.emit()
				
				_is_dragging = true
				var projected_scalar : float = event.relative.dot(_angle_vec) / _angle_vec.length_squared()
				_drag_value += projected_scalar
				
				_progress_changed(get_progress_adjusted(true))
				if smooth_drag: _adjust_children()



# Overload Functions
## Used by [method get_drawer_offset] to calculate the offset of the drawer, given the current progress. 
## Overload this method to create custom opening/closing behavior. 
func _get_drawer_offset(inner_offset : Vector2, outer_offset : Vector2, with_drag : bool = false) -> Vector2:
	#return (outer_offset - inner_offset) * get_progress_adjusted(with_drag) + inner_offset
	return inner_offset.lerp(outer_offset, get_progress_adjusted(with_drag))

# Virtual Functions

## A virtual function that is is called whenever the drawer progress changes.
func _progress_changed(progress : float) -> void: pass
