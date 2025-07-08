# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name Drawer extends Container
## A [Container] node used for easy UI Drawers.

#region Signals
## Emited when drawer is begining an opening/closing animation.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal slide_begin
## Emited when drawer is ending an opening/closing animation.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal slide_end
## Emited when state has changed, but animation has not began.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal state_toggle_begin(toggle : bool)
## Emited when state has changed and animation has finished.
## [br][br]
## Also see: [member state], [method toggle_drawer].
signal state_toggle_end(toggle : bool)
## Emited when drag has began.
## [br][br]
## Also see: [member allow_drag].
signal drag_start
## Emited when drag has ended.
## [br][br]
## Also see: [member allow_drag].
signal drag_end
#endregion


#region Enums
## A flag enum used to classify which input type is allowed.
enum ActionMode {
	ACTION_MODE_BUTTON_NONE = 0, ## Allows no input
	ACTION_MODE_BUTTON_PRESS = 1, ## Toggles the drawer on tap/click press
	ACTION_MODE_BUTTON_RELEASE = 2, ## Toggles the drawer on tap/click release
	ACTION_MODE_BUTTON_DRAG = 4, ## Allows user to drag the drawer
}

## An enum used to classify where input is accepted.
enum InputAreaMode {
	Nowhere = 0, ## No input is alloed anywhere on the screen.
	Anywhere = 1, ## Input accepted anywere on the screen.
	WithinBounds = 2, ## Input is accepted only within this node's rect.
	ExcludeDrawer = 3, ## Input is accepted anywhere except on the drawer's rect.
	WithinEmptyBounds = 4, ## Input is accepted only within this node's rect, outside of the drawer's rect.
}

## An enum used to classify when dragging is allowed.
enum DragMode {
	NEVER = 0, ## No dragging allowed.
	ON_OPEN = 1, ## Dragging is allowed to open the drawer.
	ON_CLOSE = 2, ## Dragging is allowed to close the drawer.
	ON_OPEN_OR_CLOSE = 0b11 ## Dragging is allowed to open or close the drawer.
}
#endregion


#region External Variables
@export_storage var _state : bool
## The state of the drawer. If [code]true[/code], the drawer is open. Otherwise closed.
## [br][br]
## Also see: [method toggle_drawer].
var state : bool:
	get: return _state
	set(val):
		if _state != val:
			_toggle_drawer(val)

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
			_sort_children()
## If [code]true[/code], the drawer will be snapped to move as strictly cardinally as possible.
## [br][br]
## Also see: [member drawer_angle].
var drawer_angle_axis_snap : bool:
	set(val):
		if drawer_angle_axis_snap != val:
			drawer_angle_axis_snap = val
			
			_kill_animation()
			_sort_children()

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
			_sort_children()
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
			_sort_children()

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
			_sort_children()
## Extra pixels to where the open drawer lies when closed.
var close_margin : int = 0:
	set(val):
		if val != close_margin:
			close_margin = val
			_sort_children()

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
var close_drag_threshold : int = 50:
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
#endregion


#region Private Variables
var _angle_vec : Vector2

var _animation_tween : Tween
var _current_progress : float
var _drag_value : float
var _is_dragging : bool
var _has_dragged : bool

var _inner_offset : Vector2
var _outer_offset : Vector2
var _max_offset : float
#endregion


#region Private Virtual Methods
func _init() -> void:
	_angle_vec = Vector2.RIGHT.rotated(deg_to_rad(drawer_angle))

func _get_minimum_size() -> Vector2:
	if clip_contents:
		return Vector2.ZERO
	
	var min_size : Vector2 = Vector2.ZERO
	for child : Control in _get_control_children():
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size

func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	
	ret.append({
		"name": "state",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_EDITOR
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 360, 0.001, or_less, or_greater, suffix:sec",
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_less, or_greater, suffix:px",
	}.merged({} if drawer_width_by_pixel else {
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_less, or_greater, suffix:px",
	}.merged({} if drawer_height_by_pixel else {
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_less, or_greater, suffix:px",
	})
	ret.append({
		"name": "close_margin",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_less, or_greater, suffix:px",
	})
	
	ret.append({
		"name": "Drag Options",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})
	ret.append({
		"name": "allow_drag",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(DragMode.keys()),
	})
	ret.append({
		"name": "smooth_drag",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "drag_give",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_less, or_greater, suffix:px",
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(InputAreaMode.keys()),
	})
	ret.append({
		"name": "open_drag_threshold",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, suffix:px",
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _convert_to_enum(InputAreaMode.keys()),
	})
	ret.append({
		"name": "close_drag_threshold",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 1, or_greater, suffix:px",
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
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "TransitionType"),
	})
	ret.append({
		"name": "manual_drawer_ease",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "EaseType"),
	})
	ret.append({
		"name": "manual_drawer_duration",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater, suffix:sec",
	})
	
	ret.append({
		"name": "Drag Animation",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint_string": "drag_drawer_",
	})
	ret.append({
		"name": "drag_drawer_translate",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "TransitionType"),
	})
	ret.append({
		"name": "drag_drawer_ease",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_enum_string("Tween", "EaseType"),
	})
	ret.append({
		"name": "drag_drawer_duration",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 1, 0.001, or_greater, suffix:sec",
	})
	
	return ret
func _property_can_revert(property: StringName) -> bool:
	return property in [
		"state",
		"drawer_angle",
		"drawer_angle_axis_snap",
		"drawer_width_by_pixel",
		"drawer_width",
		"drawer_height_by_pixel",
		"drawer_height",
		"action_mode",
		"drag_give",
		"open_margin",
		"close_margin",
		"allow_drag",
		"smooth_drag",
		"open_bounds",
		"open_drag_threshold",
		"close_bounds",
		"close_drag_threshold",
		"manual_drawer_translate",
		"manual_drawer_ease",
		"manual_drawer_duration",
		"drag_drawer_translate",
		"drag_drawer_ease",
		"drag_drawer_duration"
		]
func _property_get_revert(property: StringName) -> Variant:
	match property:
		"smooth_drag":
			return true
		"state", "drawer_width_by_pixel", "drawer_height_by_pixel", "drawer_angle_axis_snap":
			return false
			
		"drag_give", "open_margin", "close_margin":
			return 0
		"drawer_angle":
			return 0.0
		"manual_drawer_duration", "drag_drawer_duration":
			return 0.2
		"open_drag_threshold":
			return 50
		"close_drag_threshold":
			return 50
		
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

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton || event is InputEventScreenTouch:
		if event.pressed:
			if !_is_dragging:
				if action_mode & ActionMode.ACTION_MODE_BUTTON_PRESS:
					if !_confirm_input_accept(event, false): return
					_toggle_drawer(!is_open())
					return
				
				if action_mode & ActionMode.ACTION_MODE_BUTTON_DRAG:
					if !_confirm_input_accept(event, true): return
					drag_start.emit()
					_is_dragging = true
		else:
			if action_mode & ActionMode.ACTION_MODE_BUTTON_RELEASE:
				if _confirm_input_accept(event, false) && !_has_dragged:
					_toggle_drawer(!is_open())
					
					_has_dragged = false
					_is_dragging = false
					_drag_value = 0.0
					return
			
			if action_mode & ActionMode.ACTION_MODE_BUTTON_DRAG:
				if _is_dragging:
					drag_end.emit()
					if is_open():
						_toggle_drawer(_drag_value > -open_drag_threshold, true)
					else:
						_toggle_drawer(_drag_value > close_drag_threshold, true)
					
					set_deferred("_has_dragged", false)
					set_deferred("_is_dragging", false)
					set_deferred("_drag_value", 0.0)
					return
	
	if _is_dragging:
		if event is InputEventMouseMotion || event is InputEventScreenDrag:
			var projected_scalar : float = event.relative.dot(_angle_vec) / _angle_vec.length_squared()
			_drag_value += projected_scalar
			
			if is_zero_approx(_drag_value):
				_has_dragged = true
			
			_progress_changed(get_progress_adjusted(true))
			if smooth_drag: _adjust_children()
#endregion


#region Custom Virtual Methods
## Used by [method get_drawer_offset] to calculate the offset of the drawer, given the current progress. 
## Overload this method to create custom opening/closing behavior. 
func _get_drawer_offset(inner_offset : Vector2, outer_offset : Vector2, with_drag : bool = false) -> Vector2:
	#return (outer_offset - inner_offset) * get_progress_adjusted(with_drag) + inner_offset
	return inner_offset.lerp(outer_offset, get_progress_adjusted(with_drag))

## A virtual function that is is called whenever the drawer progress changes.
func _progress_changed(progress : float) -> void: pass
#endregion


#region Private Methods
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
func _sort_children() -> void:
	_find_offsets()
	_current_progress = _max_offset * float(_state)
	_adjust_children()
func _adjust_children() -> void:
	var rect := get_drawer_rect(true)
	for child : Control in _get_control_children():
		fit_child_in_rect(child, rect)

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
	_inner_offset = (_inner_offset + _angle_vec * open_margin).floor()
	_outer_offset = (_outer_offset - _angle_vec * close_margin).floor()


func _toggle_drawer(open : bool, drag_animate : bool = false) -> void:
	slide_begin.emit()
	_animate_to_progress(float(open), drag_animate)
	_animation_tween.tween_callback(slide_end.emit)
	
	if _state != open:
		state_toggle_begin.emit(open)
		_animation_tween.tween_callback(state_toggle_end.emit.bind(open))
		_state = open
func _animate_to_progress(
			to_progress : float,
			drag_animate : bool = false
		) -> void:
	_kill_animation()
	_animation_tween = create_tween()
	
	if drag_animate:
		_animation_tween.set_trans(drag_drawer_translate)
		_animation_tween.set_ease(drag_drawer_ease)
		_animation_tween.tween_method(
			_animation_method,
			get_progress(true),
			to_progress * _max_offset,
			drag_drawer_duration
		)
	else:
		_animation_tween.set_trans(manual_drawer_translate)
		_animation_tween.set_ease(manual_drawer_ease)
		_animation_tween.tween_method(
			_animation_method,
			get_progress(true),
			to_progress * _max_offset,
			manual_drawer_duration
		)
func _kill_animation() -> void:
	if _animation_tween && _animation_tween.is_running():
		_animation_tween.kill()
func _animation_method(progress : float) -> void:
	_current_progress = progress
	_progress_changed(get_progress_adjusted())
	_adjust_children()


func _confirm_input_accept(event : InputEvent, drag : bool = false) -> bool:
	if mouse_filter == MouseFilter.MOUSE_FILTER_IGNORE: return false
	
	var boundType : InputAreaMode
	if _state:
		boundType = close_bounds
		if drag && !(allow_drag & DragMode.ON_CLOSE):
			return false
	else:
		boundType = open_bounds
		if drag && !(allow_drag & DragMode.ON_OPEN):
			return false
	
	match boundType:
		InputAreaMode.Nowhere:
			return false
		InputAreaMode.Anywhere:
			pass
		InputAreaMode.WithinBounds:
			if !get_rect().has_point(event.position):
				return false
		InputAreaMode.ExcludeDrawer:
			if get_drawer_rect().has_point(event.position):
				if mouse_filter == MouseFilter.MOUSE_FILTER_STOP:
					get_viewport().set_input_as_handled()
				return false
		InputAreaMode.WithinEmptyBounds:
			if get_rect().intersection(get_drawer_rect()).has_point(event.position):
				if mouse_filter == MouseFilter.MOUSE_FILTER_STOP:
					get_viewport().set_input_as_handled()
				return false
	
	if mouse_filter == MouseFilter.MOUSE_FILTER_STOP:
		get_viewport().set_input_as_handled()
	return true


func _get_enum_string(className : StringName, enumName : StringName) -> String:
	var ret : String
	for constant_name in ClassDB.class_get_enum_constants(className, enumName):
		var constant_value: int = ClassDB.class_get_integer_constant(className, constant_name)
		ret += "%s:%d, " % [constant_name, constant_value]
	return ret.left(-2).replace("_", " ").capitalize().replace(", ", ",")
func _convert_to_enum(strs : PackedStringArray) -> String:
	return ", ".join(strs).replace("_", " ").capitalize().replace(", ", ",")
#endregion


#region Public Methods
## Returns if the drawer is currently open.
func is_open() -> bool:
	return get_progress_adjusted() > 0.5
## Returns if the drawer is expected to be open.
func is_open_expected() -> bool:
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
	return ret.max(get_combined_minimum_size())
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
	if _max_offset == 0.0: return 0.0
	return get_progress(include_drag, with_clamp) / _max_offset


## Allows opening and closing the drawer.
## [br][br]
## Also see: [member state] and [method force_drawer].
func toggle_drawer(open : bool) -> void:
	_toggle_drawer(open)
## Allows opening and closing the drawer without animation.
## [br][br]
## Also see: [member state] and [method toggle_drawer].
func force_drawer(open : bool) -> void:
	_kill_animation()
	_state = open
	_animation_method(float(open) * _max_offset)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
