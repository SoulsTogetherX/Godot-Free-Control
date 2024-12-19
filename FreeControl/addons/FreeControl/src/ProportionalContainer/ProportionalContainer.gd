@tool
class_name ProportionalContainer extends Container
## A container that preserves the proportions of its [member ancher] size.

enum PROPORTION_MODE {
	NONE = 0b00, ## No action. Minimum size will be set at [constant Vector2.ZERO].
	WIDTH = 0b01, ## Sets the minimum width to be equal to the [member ancher] width multipled by [member horizontal_ratio].
	HEIGHT = 0b10, ## Sets the minimum height to be equal to the [member ancher] height multipled by [member vertical_ratio].
	BOTH = 0b11 ## Sets the minimum size to be equal to the [member ancher] size multipled by [member horizontal_ratio] and [member vertical_ratio] respectively.
}

@export_group("Ancher")
## If [code]true[/code], the ancher will automatically be assumed as this node's parent.[br]
## If [code]false[/code], the ancher will be dependant on [member ancher].
## [br][br]
## Related: [method Control.get_parent_control].
@export var ancher_to_parent : bool = true:
	set(val):
		if ancher_to_parent != val:
			ancher_to_parent = val
			notify_property_list_changed()
			queue_sort()
## The ancher node this container proportions itself to. Is used if [member ancher_to_parent] is [code]false[/code].
## [br][br]
## If [code]null[/code], then this container proportions itself to screen size.
@export var ancher : Control:
	set(val):
		if ancher != val:
			ancher = val
			queue_sort()

@export_group("Proportion Mode")
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
	sort_children.connect(_handel_resize)
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
	elif property.name == "ancher":
		if ancher_to_parent:
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "horizontal_ratio":
		if !(mode & PROPORTION_MODE.WIDTH):
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "vertical_ratio":
		if !(mode & PROPORTION_MODE.HEIGHT):
			property.usage |= PROPERTY_USAGE_READ_ONLY

func _handel_resize() -> void:
	if !is_inside_tree(): return
	if mode == PROPORTION_MODE.NONE:
		_min_size = Vector2.ZERO
		update_minimum_size()
		return
	
	var ancher_size : Vector2;
	if ancher:
		ancher_size = ancher.size
	elif ancher_to_parent && get_parent_control():
		ancher_size = get_parent_control().size
	elif Engine.is_editor_hint():
		var edited_scene_root := get_tree().get_edited_scene_root()
		var scene_root_parent := edited_scene_root if edited_scene_root.get_parent_control() else null
		
		if scene_root_parent && get_viewport() == scene_root_parent.get_viewport():
			ancher_size = Vector2(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
		else:
			ancher_size = get_viewport().get_visible_rect().size
	else:
		ancher_size = get_viewport().get_visible_rect().size
	
	var container_size : Vector2 = size
	if mode & PROPORTION_MODE.WIDTH > 0:
		ancher_size.x = ancher_size.x * horizontal_ratio
	
	if mode & PROPORTION_MODE.HEIGHT > 0:
		ancher_size.y = ancher_size.y * vertical_ratio
	
	_min_size = ancher_size
	update_minimum_size()
	_fit_children()
func _fit_children() -> void:
	for child in get_children(true):
		if child is Control:
			fit_child_in_rect(child, Rect2(Vector2.ZERO, _min_size))
func _get_minimum_size() -> Vector2:
	return _min_size
