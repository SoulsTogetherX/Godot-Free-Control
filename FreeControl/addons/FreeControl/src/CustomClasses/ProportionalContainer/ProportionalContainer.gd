# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name ProportionalContainer extends Container
## A container that preserves the proportions of its [member ancher] size.
## [br][br]
## [b]WARNING[b]: Is this can cause crashes if misused. Try to use [PaddingContainer] instead, unless required.

#region Enums
## The method this node will change in proportion of its [member ancher] size.
enum PROPORTION_MODE {
	NONE = 0b000, ## No action. Minimum size will be set at [constant Vector2.ZERO].
	WIDTH = 0b101, ## Same as [WIDTH_PROPORTION], but also sets children height to be equal to the [member ancher]'s size's height.
	WIDTH_PROPORTION = 0b001, ## Sets the minimum width to be equal to the [member ancher] width multipled by [member horizontal_ratio].
	HEIGHT = 0b110, ## Same as [HEIGHT_PROPORTION], but also sets children height to be equal to the [member ancher]'s size's width.
	HEIGHT_PROPORTION = 0b010, ## Sets the minimum height to be equal to the [member ancher] height multipled by [member vertical_ratio].
	BOTH = 0b011 ## Sets the minimum size to be equal to the [member ancher] size multipled by [member horizontal_ratio] and [member vertical_ratio] respectively.
}
#endregion


#region External Variables
@export_group("Ancher")
## The ancher node this container proportions itself to. Is used if [member ancher_to_parent] is [code]false[/code].
## [br][br]
## If [code]null[/code], then this container proportions itself to it's parent control size.
@export var ancher : Control:
	set(val):
		if ancher != val:
			if ancher && ancher.resized.is_connected(_sort_children):
				ancher.resized.disconnect(_sort_children)
			if val && !val.resized.is_connected(_sort_children):
				val.resized.connect(_sort_children)
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
#endregion


#region Private Variables
var _min_size : Vector2
var _ignore_resize : bool
#endregion


#region Private Virtual Methods
func _init() -> void:
	layout_mode = 0
	clip_contents = false
func _ready() -> void:
	_sort_children()

func _get_minimum_size() -> Vector2:
	return _min_size

func _validate_property(property: Dictionary) -> void:
	if property.name in [
		"layout_mode",
		"size",
		"clip_contents"
	]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "horizontal_ratio":
		if !(mode & PROPORTION_MODE.WIDTH_PROPORTION):
			property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "vertical_ratio":
		if !(mode & PROPORTION_MODE.HEIGHT_PROPORTION):
			property.usage |= PROPERTY_USAGE_READ_ONLY

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
#endregion


#region Private Methods
func _sort_children() -> void:
	if _ignore_resize: return
	_ignore_resize = true
	
	if mode != PROPORTION_MODE.NONE:
		# Sets the min size according to it's dimentions and proportion mode
		
		var ancher_size : Vector2 = get_parent_area_size()
		if ancher: ancher_size = ancher.size
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
	elif _min_size != Vector2.ZERO:
		# Sets min size to default
		
		_min_size = Vector2.ZERO
		update_minimum_size()
	
	_ignore_resize = false
	_fit_children()


func _fit_children() -> void:
	for child : Control in _get_control_children():
		_fit_child(child)
func _fit_child(child : Control) -> void:
	var child_size := child.get_minimum_size()
	var ancher_size : Vector2 = ancher.size if ancher else get_parent_area_size()
	var set_pos : Vector2
	
	# Gets the ancher_size according to this node's dimentions and proportion mode
	if mode & PROPORTION_MODE.WIDTH_PROPORTION > 0:
		ancher_size.x = ancher_size.x * horizontal_ratio
		
		# Expands or repositions child, according to ancher and size flages
		match child.size_flags_horizontal & ~SIZE_EXPAND:
			SIZE_FILL:
				child_size.x = ancher_size.x
				set_pos.x = 0
			SIZE_SHRINK_BEGIN:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = 0
			SIZE_SHRINK_CENTER:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = max((ancher_size.x - child_size.x) * 0.5, 0)
			SIZE_SHRINK_END:
				child_size.x = max(child_size.x, ancher_size.x)
				set_pos.x = max(ancher_size.x - child_size.x, 0)
		if mode == PROPORTION_MODE.WIDTH:
			child_size.y = size.y
		
	# Gets the ancher_size according to this node's dimentions and proportion mode
	if mode & PROPORTION_MODE.HEIGHT_PROPORTION > 0:
		ancher_size.y = ancher_size.y * vertical_ratio
		
		# Expands or repositions child, according to ancher and size flages
		match child.size_flags_vertical & ~SIZE_EXPAND:
			SIZE_FILL:
				child_size.y = ancher_size.y
				set_pos.y = 0
			SIZE_SHRINK_BEGIN:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = 0
			SIZE_SHRINK_CENTER:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = max((size.y - child_size.y) * 0.5, 0)
			SIZE_SHRINK_END:
				child_size.y = max(child_size.y, ancher_size.y)
				set_pos.y = max(size.y - child_size.y, 0)
		if mode == PROPORTION_MODE.HEIGHT:
			child_size.x = size.x
	
	fit_child_in_rect(child, Rect2(set_pos, child_size))
func _get_children_min_size() -> Vector2:
	var ret := Vector2.ZERO
	for child : Control in _get_control_children():
		ret = ret.max(child.get_combined_minimum_size())
	return ret
func _get_control_children() -> Array[Control]:
	var ret : Array[Control]
	ret.assign(get_children().filter(func(child : Node): return child is Control && child.visible))
	return ret
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
