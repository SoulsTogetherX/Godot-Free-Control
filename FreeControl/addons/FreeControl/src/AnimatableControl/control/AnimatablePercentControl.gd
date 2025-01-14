# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatablePercentControl extends AnimatableScrollControl
## A container to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress.

## Modes of zone type checking.
enum CHECK_MODE {
	NONE = 0b000, ## No behavior.
	HORIZONTAL = 0b001, ## Only checks if this node is in the zone horizontally.
	VERTICAL = 0b010, ## Only checks if this node is in the zone vertically.
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
## This is only relevant if [member check_mode] is either [constant CHECK_MODE.VERTICAL] or  [constant CHECK_MODE.BOTH].
@export_range(0, 1, 0.01, "or_greater") var zone_range_horizontal : float = 0.05:
	set(val):
		if zone_range_horizontal != val:
			zone_range_horizontal = val
			_scrolled_horizontal(get_scroll_offset().x)
			queue_redraw()
## The horizontal spread of the zone, from it's origin.[br]
## This is only relevant if [member check_mode] is either [constant CHECK_MODE.HORIZONTAL] or  [constant CHECK_MODE.BOTH].
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
		_while_in_zone(is_visible_percent())
	elif _last_overlapped:
		_on_zone_exit()
func _scrolled_vertical(scroll_ver : float) -> void:
	if !(check_mode & CHECK_MODE.VERTICAL) || !scroll: return
	
	var overlapped := is_overlaped_with_activate_zone()
	if overlapped:
		if !_last_overlapped:
			_on_zone_enter()
			_last_overlapped = overlapped
		_while_in_zone(is_visible_percent())
	elif _last_overlapped:
		_on_zone_exit()

func _draw() -> void:
	if !_mount || !Engine.is_editor_hint() || hide_indicator: return
	if check_mode == CHECK_MODE.NONE: return
	
	draw_set_transform(global_position - scroll.global_position)
	
	var draw_rect := scroll.get_rect()
	var goal_pos := Vector2(zone_horizontal, zone_vertical) * scroll.size
	var goal_range := Vector2(zone_range_horizontal, zone_range_vertical) * scroll.size
	
	if (check_mode == CHECK_MODE.VERTICAL):
		var pos := goal_pos.y - goal_range.y
		var max_pos := max(pos, 0)
		
		draw_rect.position.y = max_pos
		draw_rect.size.y = min(goal_range.y + goal_range.y + pos, scroll.size.y) - max_pos
	elif (check_mode == CHECK_MODE.HORIZONTAL):
		var pos := goal_pos.x - goal_range.x
		var max_pos := max(pos, 0)
		
		draw_rect.position.x = max_pos
		draw_rect.size.x = min(goal_range.x + goal_range.x + pos, scroll.size.x) - max_pos
	elif (check_mode == CHECK_MODE.BOTH):
		var pos := goal_pos - goal_range
		var max_pos := pos.max(Vector2.ZERO)
		
		draw_rect.position = max_pos
		draw_rect.size = scroll.size.min(goal_range + goal_range + pos) - max_pos
	
	var scroll_transform := scroll.get_global_transform()
	var transform := get_global_transform()
	
	draw_set_transform(scroll_transform.get_origin() - transform.get_origin(),
	scroll_transform.get_rotation() - transform.get_rotation(),
	scroll_transform.get_scale() / transform.get_scale())
	draw_rect(draw_rect, HIGHLIGHT_COLOR)

## A virtual function that is called while this node is in the zone area. Is called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current visible percent.
func _while_in_zone(_intersect : float) -> void: pass
## A virtual function that is called when this node entered the zone area.
func _on_zone_enter() -> void: pass
## A virtual function that is called when this node exited the zone area.
func _on_zone_exit() -> void: pass

## Returns [code]true[/code] if this node is overlaping the zone area.[br]
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
