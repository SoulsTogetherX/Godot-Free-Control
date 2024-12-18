@tool
class_name ProportionalContainer extends Container

enum PROPORTION_MODE {
	NONE = 0b00,
	WIDTH = 0b01,
	HEIGHT = 0b10,
	BOTH = 0b11
}

@export var ancher_to_parent : bool:
	set(val):
		if ancher_to_parent != val:
			ancher_to_parent = val
			notify_property_list_changed()
			queue_sort()
@export var ancher : Control:
	set(val):
		if ancher != val:
			ancher = val
			queue_sort()
@export var mode : PROPORTION_MODE = PROPORTION_MODE.NONE:
	set(val):
		if mode != val:
			mode = val
			notify_property_list_changed()
			queue_sort()
@export_range(0., 1.) var horizontal_ratio : float = 1.:
	set(val):
		if horizontal_ratio != val:
			horizontal_ratio = val
			queue_sort()
@export_range(0., 1.) var vertical_ratio : float = 1.:
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
	elif ancher_to_parent && get_parent() && get_parent() is Control:
		ancher_size = get_parent().size
	elif Engine.is_editor_hint():
		var edited_scene_root := get_tree().get_edited_scene_root()
		var scene_root_parent := edited_scene_root if edited_scene_root.get_parent() else null
		
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
