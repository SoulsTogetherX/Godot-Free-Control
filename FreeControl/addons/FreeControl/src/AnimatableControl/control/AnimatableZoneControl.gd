# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableZoneControl extends AnimatableScrollControl
## A container to be used for free transformation, within a UI, depended on a
## [ScrollContainer]'s scroll progress.

## Modes of zone type checking.
enum CHECK_MODE {
	NONE = 0b000, ## No behavior.
	HORIZONTAL = 0b001, ## Only checks if this node's mount is in the zone horizontally.
	VERTICAL = 0b010, ## Only checks if this node's mount is in the zone vertically.
	BOTH = 0b011 ## Checks horizontally and vertically.
}

## Modes of zone size and center position.
enum ZONE_EDITOR_DIMS {
	None = 0b00, ## Both horizontal and vertical axis are based on ratio.
	Horizontal = 0b01, ## Horizontal axis is based on exact pixel and vertical on ratio.
	Vertical = 0b10, ## Horizontal axis is based on ratio and vertical on exact pixel.
	Both = 0b11, ## Both horizontal and vertical axis are based on exact pixel.
}

## Color for inner highlighting - Indicates when visiblity is required to met threshold.
const HIGHLIGHT_COLOR := Color(Color.RED, 0.3)

@export_group("Mode")
## Sets the mode of zone checking.
@export var check_mode: CHECK_MODE = CHECK_MODE.NONE:
	set(val):
		if check_mode != val:
			check_mode = val
			notify_property_list_changed()
			queue_redraw()

## A flag variable used to distinguish if the center of the zone is described by
## a ratio of the size of the [member AnimatableScrollControl.scroll] value, or
## by a const pixel value.[br]
## Horizontal and vertical axis are consistered differently.
## [br][br]
## See [enum ZONE_EDITOR_DIMS], [member zone_horizontal], and [member zone_vertical].
var zone_point_pixel : int = 0:
	set(val):
		if (zone_point_pixel ^ val) & ZONE_EDITOR_DIMS.Horizontal:
			_scrolled_horizontal(get_scroll_offset().x)
		if (zone_point_pixel ^ val) & ZONE_EDITOR_DIMS.Vertical:
			_scrolled_vertical(get_scroll_offset().y)
		zone_point_pixel = val
		notify_property_list_changed()
		queue_redraw()
var _zone_horizontal : float = 0.5
## The horizontal position of the zone's center, described either as the ratio of
## the size of the [member AnimatableScrollControl.scroll] value, or by a const
## pixel value.[br]
## [br][br]
## See [member zone_point_pixel]
var zone_horizontal : float:
	get: return _zone_horizontal
	set(val):
		if _zone_horizontal != val:
			_zone_horizontal = val
			_scrolled_horizontal(get_scroll_offset().x)
			queue_redraw()
var _zone_vertical : float = 0.5
## The vertical position of the zone's center, described either as the ratio of
## the size of the [member AnimatableScrollControl.scroll] value, or by a const
## pixel value.[br]
## [br][br]
## See [member zone_point_pixel]
var zone_vertical : float = 0.5:
	get: return _zone_vertical
	set(val):
		if _zone_vertical != val:
			_zone_vertical = val
			_scrolled_vertical(get_scroll_offset().y)
			queue_redraw()

## A flag variable used to distinguish if the size of the zone is described by
## a ratio of the size of the [member AnimatableScrollControl.scroll] value, or
## by a const pixel value.[br]
## Horizontal and vertical axis are consistered differently.
## [br][br]
## See [enum ZONE_EDITOR_DIMS], [member zone_horizontal], and [member zone_vertical].
var zone_range_by_pixel : int = 0:
	set(val):
		if (zone_point_pixel ^ val) & ZONE_EDITOR_DIMS.Horizontal:
			_scrolled_horizontal(get_scroll_offset().x)
		if (zone_point_pixel ^ val) & ZONE_EDITOR_DIMS.Vertical:
			_scrolled_horizontal(get_scroll_offset().y)
		zone_range_by_pixel = val
		notify_property_list_changed()
		queue_redraw()
var _zone_range_horizontal : float = 0.05
## The horizontal size of the zone, described either as the ratio of the size
## of the [member AnimatableScrollControl.scroll] value, or by a const pixel
## value.[br]
## [br][br]
## See [member zone_vertical]
var zone_range_horizontal : float:
	get: return _zone_range_horizontal
	set(val):
		if _zone_range_horizontal != val:
			_zone_range_horizontal = val
			_scrolled_horizontal(get_scroll_offset().x)
			queue_redraw()
var _zone_range_vertical : float = 0.05
## The vertical size of the zone, described either as the ratio of the size
## of the [member AnimatableScrollControl.scroll] value, or by a const pixel
## value.[br]
## [br][br]
## See [member zone_vertical]
var zone_range_vertical : float:
	get: return _zone_range_vertical
	set(val):
		if _zone_range_vertical != val:
			_zone_range_vertical = val
			_scrolled_vertical(get_scroll_offset().y)
			queue_redraw()

## [b]Editor usage only.[/b] Shows or hides the helpful threshold highlighter.
var hide_indicator : bool = false:
	set(val):
		if hide_indicator != val:
			hide_indicator = val
			queue_redraw()

var _last_overlapped : bool

func _draw() -> void:
	if !_mount || !Engine.is_editor_hint() || hide_indicator || !scroll || check_mode == CHECK_MODE.NONE: return
	
	var draw_rect := get_zone_rect()
	var scroll_transform := scroll.get_global_transform()
	var transform := _mount.get_global_transform()
	
	draw_set_transform(scroll_transform.get_origin() - transform.get_origin(),
	scroll_transform.get_rotation() - transform.get_rotation(),
	scroll_transform.get_scale() / transform.get_scale())
	draw_rect(draw_rect, HIGHLIGHT_COLOR)

func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary] = []
	var horizontal : int = 0 if check_mode & CHECK_MODE.HORIZONTAL else PROPERTY_USAGE_READ_ONLY
	var vertical : int = 0 if check_mode & CHECK_MODE.VERTICAL else PROPERTY_USAGE_READ_ONLY
	var either : int = horizontal & vertical
	
	var options : String
	if !horizontal: options = "Horizontal:1,"
	if !vertical: options += "Vertical:2"
	
	ret.append({
		"name": "Zone Point",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_string": ""
	})
	ret.append({
		"name": "zone_point_pixel",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": options,
		"usage": PROPERTY_USAGE_DEFAULT | either
	})
	ret.append({
		"name": "zone_horizontal",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | horizontal
	}.merged({} if zone_point_pixel & 1 else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.01,or_less,or_greater"
	}))
	ret.append({
		"name": "zone_vertical",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | vertical
	}.merged({} if zone_point_pixel & 2 else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.01,or_less,or_greater"
	}))
	
	ret.append({
		"name": "Zone Range",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_string": ""
	})
	ret.append({
		"name": "zone_range_by_pixel",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": options,
		"usage": PROPERTY_USAGE_DEFAULT | either
	})
	ret.append({
		"name": "zone_range_horizontal",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | horizontal
	}.merged({} if zone_range_by_pixel & 1 else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.01,or_less,or_greater"
	}))
	ret.append({
		"name": "zone_range_vertical",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | vertical
	}.merged({} if zone_range_by_pixel & 2 else {
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.01,or_less,or_greater"
	}))
	
	ret.append({
		"name": "Indicator",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_str": ""
	})
	ret.append({
		"name": "hide_indicator",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	return ret
func _property_can_revert(property: StringName) -> bool:
	if property in ["zone_point_pixel", "zone_range_by_pixel"]:
		if self[property] != 0: return true
	elif property in ["zone_horizontal", "zone_vertical"]:
		if self[property] != 0.5: return true
	elif property in ["zone_range_horizontal", "zone_range_vertical"]:
		if self[property] != 0.05: return true
	elif property == "hide_indicator":
		return hide_indicator
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property in ["zone_point_pixel", "zone_range_by_pixel"]:
		return 0
	elif property in ["zone_horizontal", "zone_vertical"]:
		return 0.5
	elif property in ["zone_range_horizontal", "zone_range_vertical"]:
		return 0.05
	elif property == "hide_indicator":
		return false
	return null

func _scrolled_horizontal(scroll_hor : float) -> void:
	if !(check_mode & CHECK_MODE.HORIZONTAL) || !scroll: return
	
	var overlapped := is_overlaped_with_activate_zone()
	if overlapped:
		if !_last_overlapped:
			_on_zone_enter()
			_last_overlapped = true
		_while_in_zone(zone_local_scroll().x)
	elif _last_overlapped:
		_last_overlapped = false
		_while_in_zone(1 if zone_local_scroll().x > 0.5 else 0)
		_on_zone_exit()
func _scrolled_vertical(scroll_ver : float) -> void:
	if !(check_mode & CHECK_MODE.VERTICAL) || !scroll: return
	
	var overlapped := is_overlaped_with_activate_zone()
	if overlapped:
		if !_last_overlapped:
			_on_zone_enter()
			_last_overlapped = true
		_while_in_zone(zone_local_scroll().y)
	elif _last_overlapped:
		_last_overlapped = false
		_while_in_zone(1 if zone_local_scroll().y > 0.5 else 0)
		_on_zone_exit()

## A virtual function that is called while this node is in the zone area. Is called
## after each scroll of [member scroll].
## [br][br]
## Paramter [param _scroll] is the local scroll within the zone.
func _while_in_zone(_scroll : float) -> void: pass
## A virtual function that is called when this node entered the zone area.
func _on_zone_enter() -> void: pass
## A virtual function that is called when this node exited the zone area.
func _on_zone_exit() -> void: pass

func _get_zone_pos() -> Vector2:
	var ret := Vector2(zone_horizontal, zone_vertical)
	if zone_point_pixel == ZONE_EDITOR_DIMS.None:
		ret *= scroll.size
	elif zone_point_pixel == ZONE_EDITOR_DIMS.Vertical:
		ret.x *= scroll.size.x
	elif zone_point_pixel == ZONE_EDITOR_DIMS.Horizontal:
		ret.y *= scroll.size.y
	return ret
func _get_zone_range() -> Vector2:
	var ret := Vector2(zone_range_horizontal, zone_range_vertical) * 0.5
	if zone_range_by_pixel == ZONE_EDITOR_DIMS.None:
		ret *= scroll.size
	elif zone_range_by_pixel == ZONE_EDITOR_DIMS.Vertical:
		ret.x *= scroll.size.x
	elif zone_range_by_pixel == ZONE_EDITOR_DIMS.Horizontal:
		ret.y *= scroll.size.y
	return ret

## Returns [code]true[/code] if this node's mount is overlaping the zone area.[br]
## This function's value is dependant on the value of [member check_mode].
func is_overlaped_with_activate_zone() -> bool:
	var item_pos_start := get_origin_offset()
	var item_pos_end := item_pos_start + size
	
	var zone_pos := _get_zone_pos()
	var zone_range := _get_zone_range()
	var zone_pos_start := zone_pos - zone_range
	var zone_pos_end := zone_pos + zone_range
	
	if (check_mode == CHECK_MODE.VERTICAL):
		return (zone_pos_start.y <= item_pos_end.y && zone_pos_end.y >= item_pos_start.y)
	elif (check_mode == CHECK_MODE.HORIZONTAL):
		return (zone_pos_start.x <= item_pos_end.x && zone_pos_end.x >= item_pos_start.x)
	elif (check_mode == CHECK_MODE.BOTH):
		return (zone_pos_start.y <= item_pos_end.y && zone_pos_end.y >= item_pos_start.y) && (zone_pos_start.x <= item_pos_end.x && zone_pos_end.x >= item_pos_start.x)
	return false

## Gets the Rect2 associated to the zone.
## [br][br]
## Also see [method get_zone_global_rect], [member zone_horizontal],
## [member zone_vertical], [member zone_range_horizontal], [member zone_range_vertical].
func get_zone_rect() -> Rect2:
	if check_mode == CHECK_MODE.NONE || !scroll: return Rect2()
	
	var ret : Rect2 = scroll.get_rect()
	var zone_pos := _get_zone_pos()
	var zone_range := _get_zone_range()
	
	if (check_mode == CHECK_MODE.VERTICAL):
		var pos := zone_pos.y - zone_range.y
		var max_pos := max(pos, 0)
		
		ret.position.y = max_pos
		ret.size.y = min(zone_range.y + zone_range.y + pos, scroll.size.y) - max_pos
	elif (check_mode == CHECK_MODE.HORIZONTAL):
		var pos := zone_pos.x - zone_range.x
		var max_pos := max(pos, 0)
		
		ret.position.x = max_pos
		ret.size.x = min(zone_range.x + zone_range.x + pos, scroll.size.x) - max_pos
	elif (check_mode == CHECK_MODE.BOTH):
		var pos := zone_pos - zone_range
		var max_pos := pos.max(Vector2.ZERO)
		
		ret.position = max_pos
		ret.size = scroll.size.min(zone_range + zone_range + pos) - max_pos
	return ret
## Gets the global Rect2 associated to the zone.
## [br][br]
## Also see [method get_zone_rect], [member zone_horizontal], [member zone_vertical],
## [member zone_range_horizontal], [member zone_range_vertical].
func get_zone_global_rect() -> Rect2:
	var zone_rect := get_zone_rect()
	zone_rect.position -= scroll.global_position
	return zone_rect
## Gets the percentage of this node's mount intersection with the zone.
## [br][br]
## Also see [method get_zone_rect], [method get_zone_global_rect].
func in_zone_percent() -> float:
	if !_mount: return 0
	return (_mount.get_global_rect().intersection(get_zone_global_rect()).get_area()) / (_mount.size.x * _mount.size.y)
## The local scroll within the zone zone. Returns [code]0[/code] if this node's
## mount is not inside the zone area.
## [br][br]
## Also see [method get_zone_rect], [method get_zone_global_rect].
func zone_local_scroll() -> Vector2:
	var zone := get_zone_global_rect()
	var mount := _mount.get_global_rect()
	return (_mount.global_position - zone.position + mount.size) / (zone.size + mount.size)
