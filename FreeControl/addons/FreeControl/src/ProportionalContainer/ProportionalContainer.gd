# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name ProportionalContainer extends Container
## A container that preserves the proportions of its [member ancher] size.

## The method this node will change in proportion of its [member ancher] size.
enum PROPORTION_MODE {
	NONE = 0b00, ## No action. Minimum size will be set at [constant Vector2.ZERO].
	WIDTH = 0b01, ## Sets the minimum width to be equal to the [member ancher] width multipled by [member horizontal_ratio].
	HEIGHT = 0b10, ## Sets the minimum height to be equal to the [member ancher] height multipled by [member vertical_ratio].
	BOTH = 0b11 ## Sets the minimum size to be equal to the [member ancher] size multipled by [member horizontal_ratio] and [member vertical_ratio] respectively.
}

@export_group("Ancher")
## The ancher node this container proportions itself to. Is used if [member ancher_to_parent] is [code]false[/code].
## [br][br]
## If [code]null[/code], then this container proportions itself to it's parent control size.
@export var ancher : Control:
	set(val):
		if ancher != val:
			ancher = val
			queue_sort()

@export_group("Proportion")
## The proportion mode used to scale itself to the [member ancher].
@export var mode : PROPORTION_MODE = PROPORTION_MODE.NONE:
	set(val):
		if mode != val:
			mode = val
			notify_property_list_changed()
			queue_sort()
## The multiplicative of this node's width to the [member ancher] width.
@export_range(0., 1., 0.001, "or_greater") var horizontal_ratio : float = 1.:
	set(val):
		if horizontal_ratio != val:
			horizontal_ratio = val
			queue_sort()
## The multiplicative of this node's height to the [member ancher] height.
@export_range(0., 1., 0.001, "or_greater") var vertical_ratio : float = 1.:
	set(val):
		if vertical_ratio != val:
			vertical_ratio = val
			queue_sort()

var _min_size : Vector2

func _ready() -> void:
	layout_mode = 0
	if !sort_children.is_connected(_handel_resize):
		sort_children.connect(_handel_resize, CONNECT_PERSIST)
	
	_handel_resize()
func _validate_property(property: Dictionary) -> void:
	if property.name in [
		"layout_mode",
		"size",
		"position",
		"rotation",
		"scale",
		"pivot_offset"
	]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "horizontal_ratio":
		if !(mode & PROPORTION_MODE.WIDTH):
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "vertical_ratio":
		if !(mode & PROPORTION_MODE.HEIGHT):
			property.usage |= PROPERTY_USAGE_READ_ONLY
func _get_minimum_size() -> Vector2:
	return _min_size

func _handel_resize() -> void:
	if !is_inside_tree(): return
	if mode == PROPORTION_MODE.NONE:
		_min_size = Vector2.ZERO
		update_minimum_size()
		return
	
	# Sets the min size according to it's dimentions and proportion mode
	var ancher_size : Vector2 = get_parent_area_size()
	if ancher:
		if !ancher.is_node_ready():
			await ancher.ready
			await get_tree().process_frame
		ancher_size = ancher.size
	var child_min_size := _get_children_min_size()
	var _old_min_size := _min_size
	
	if mode & PROPORTION_MODE.WIDTH != 0:
		_min_size.x = ancher_size.x * horizontal_ratio
	else:
		_min_size.x = child_min_size.x
	if mode & PROPORTION_MODE.HEIGHT != 0:
		_min_size.y = ancher_size.y * vertical_ratio
	else:
		_min_size.y = child_min_size.y
	
	if _min_size != _old_min_size:
		update_minimum_size()
	_fit_children()

func _fit_children() -> void:
	for child: Control in get_children(true):
		if child:_fit_child(child)
func _fit_child(child : Control) -> void:
	var child_size := child.get_minimum_size()
	var ancher_size : Vector2 = ancher.size if ancher else get_parent_area_size()
	var set_pos : Vector2
	
	# Gets the ancher_size according to this node's dimentions and proportion mode
	if mode & PROPORTION_MODE.WIDTH > 0:
		ancher_size.x = ancher_size.x * horizontal_ratio
		
		# Expands or repositions child, according to ancher and size flages
		match child.size_flags_horizontal & ~SIZE_EXPAND:
			SIZE_FILL:
				child_size.x = ancher_size.x
				set_pos.x =  max((size.x - ancher_size.x) * 0.5, 0)
			SIZE_SHRINK_BEGIN:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = 0
			SIZE_SHRINK_CENTER:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = max((ancher_size.x - child_size.x) * 0.5, 0)
			SIZE_SHRINK_END:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = max(ancher_size.x - child_size.x, 0)
	
	# Gets the ancher_size according to this node's dimentions and proportion mode
	if mode & PROPORTION_MODE.HEIGHT > 0:
		ancher_size.y = ancher_size.y * vertical_ratio
		
		# Expands or repositions child, according to ancher and size flages
		match child.size_flags_vertical & ~SIZE_EXPAND:
			SIZE_FILL:
				child_size.y = ancher_size.y
				set_pos.y = max((size.y - ancher_size.y) * 0.5, 0)
			SIZE_SHRINK_BEGIN:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = 0
			SIZE_SHRINK_CENTER:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = max((size.y - child_size.y) * 0.5, 0)
			SIZE_SHRINK_END:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = max(size.y - child_size.y, 0)
	
	fit_child_in_rect(child, Rect2(set_pos, child_size))
func _get_children_min_size() -> Vector2:
	var ret := Vector2.ZERO
	for child : Node in get_children(true):
		if child is Control:
			ret = ret.max(child.get_combined_minimum_size())
	return ret
	
func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
