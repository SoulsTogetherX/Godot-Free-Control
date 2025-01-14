# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatablePercentControl extends AnimatableScrollControl
## A container to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress.

## Modes of zone type checking.
enum CHECK_MODE {
	NONE = 0b000, ## No behavior.
	HORIZONTAL = 0b001, ## Only checks if this node's mount is in the zone horizontally.
	VERTICAL = 0b010, ## Only checks if this node's mount is in the zone vertically.
	BOTH = 0b011 ## Checks horizontally and vertically.
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

@export_group("Zone Point")
## The horizontal origin of the zone's center, within the bounds of the [memeber AnimatableScrollControl.scroll].
## [br][br]
## If [code]0[/code], the origin will be at the far left. If [code]1[/code], the origin will be at the far right. 
@export_range(0, 1) var zone_horizontal : float = 0.5:
	set(val):
		if zone_horizontal != val:
			zone_horizontal = val
			_scrolled_horizontal(get_scroll_offset().x)
			queue_redraw()
## The vertical origin of the zone's center, within the bounds of the [memeber AnimatableScrollControl.scroll].
## [br][br]
## If [code]0[/code], the origin will be at the far top. If [code]1[/code], the origin will be at the far bottom. 
@export_range(0, 1) var zone_vertical : float = 0.5:
	set(val):
		if zone_vertical != val:
			zone_vertical = val
			_scrolled_vertical(get_scroll_offset().y)
			queue_redraw()

@export_group("Zone Range")
## The vertical spread of the zone, from it's origin.[br]
## This is only relevant if [member check_mode] is either [constant CHECK_MODE.VERTICAL] or [constant CHECK_MODE.BOTH].
@export_range(0, 1, 0.01, "or_greater") var zone_range_horizontal : float = 0.05:
	set(val):
		if zone_range_horizontal != val:
			zone_range_horizontal = val
			_scrolled_horizontal(get_scroll_offset().x)
			queue_redraw()
## The horizontal spread of the zone, from it's origin.[br]
## This is only relevant if [member check_mode] is either [constant CHECK_MODE.HORIZONTAL] or [constant CHECK_MODE.BOTH].
@export_range(0, 1, 0.01, "or_greater") var zone_range_vertical : float = 0.05:
	set(val):
		if zone_range_vertical != val:
			zone_range_vertical = val
			_scrolled_vertical(get_scroll_offset().y)
			queue_redraw()

@export_group("Indicator")
## [b]Editor usage only.[/b]
## [br]
## Shows or hides the helpful threshold highlighter.
@export var hide_indicator : bool = false:
	set(val):
		if hide_indicator != val:
			hide_indicator = val
			queue_redraw()

var _last_overlapped : bool

func _scrolled_horizontal(_scroll_hor : float) -> void:
	if !(check_mode & CHECK_MODE.HORIZONTAL) || !scroll: return
	
	var overlapped := is_overlaped_with_activate_zone()
	if overlapped:
		if !_last_overlapped:
			_on_zone_enter()
			_last_overlapped = overlapped
		_while_in_zone(in_zone_percent())
	elif _last_overlapped:
		_while_in_zone(0)
		_on_zone_exit()
func _scrolled_vertical(scroll_ver : float) -> void:
	if !(check_mode & CHECK_MODE.VERTICAL) || !scroll: return
	
	var overlapped := is_overlaped_with_activate_zone()
	if overlapped:
		if !_last_overlapped:
			_on_zone_enter()
			_last_overlapped = overlapped
		_while_in_zone(in_zone_percent())
	elif _last_overlapped:
		_while_in_zone(0)
		_on_zone_exit()

func _draw() -> void:
	if !_mount || !Engine.is_editor_hint() || hide_indicator || !scroll || check_mode == CHECK_MODE.NONE: return
	
	var draw_rect := get_zone_rect()
	
	var scroll_transform := scroll.get_global_transform()
	var transform := _mount.get_global_transform()
	
	draw_set_transform(scroll_transform.get_origin() - transform.get_origin(),
	scroll_transform.get_rotation() - transform.get_rotation(),
	scroll_transform.get_scale() / transform.get_scale())
	draw_rect(draw_rect, HIGHLIGHT_COLOR)

## A virtual function that is called while this node is in the zone area. Is called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current percentage of this node's mount intersecting the zone area.
func _while_in_zone(_intersect : float) -> void: pass
## A virtual function that is called when this node entered the zone area.
func _on_zone_enter() -> void: pass
## A virtual function that is called when this node exited the zone area.
func _on_zone_exit() -> void: pass

## Returns [code]true[/code] if this node's mount is overlaping the zone area.[br]
## This function's value is dependant on the value of [member check_mode].
func is_overlaped_with_activate_zone() -> bool:
	var item_pos_start := get_origin_offset()
	var item_pos_end := item_pos_start + size
	
	var goal_pos := Vector2(zone_horizontal, zone_vertical) * scroll.size
	var goal_range := Vector2(zone_range_horizontal, zone_range_vertical) * scroll.size
	var goal_pos_start := goal_pos - goal_range
	var goal_pos_end := goal_pos + goal_range
	
	if (check_mode == CHECK_MODE.VERTICAL):
		return (goal_pos_start.y <= item_pos_end.y && goal_pos_end.y >= item_pos_start.y)
	elif (check_mode == CHECK_MODE.HORIZONTAL):
		return (goal_pos_start.x <= item_pos_end.x && goal_pos_end.x >= item_pos_start.x)
	elif (check_mode == CHECK_MODE.BOTH):
		return (goal_pos_start.y <= item_pos_end.y && goal_pos_end.y >= item_pos_start.y) && (goal_pos_start.x <= item_pos_end.x && goal_pos_end.x >= item_pos_start.x)
	return false

## Gets the Rect2 associated to the zone.
## [br][br]
## Also see [method get_zone_global_rect], [member zone_horizontal], [member zone_vertical], [member zone_range_horizontal], [member zone_range_vertical].
func get_zone_rect() -> Rect2:
	if check_mode == CHECK_MODE.NONE || !scroll: return Rect2()
	
	var ret : Rect2 = scroll.get_rect()
	var zone_pos := Vector2(zone_horizontal, zone_vertical) * scroll.size
	var zone_range := Vector2(zone_range_horizontal, zone_range_vertical) * scroll.size
	
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
## Also see [method get_zone_rect], [member zone_horizontal], [member zone_vertical], [member zone_range_horizontal], [member zone_range_vertical].
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
