# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxRatioContainer extends MaxSizeContainer
## A container that limits an axis of it's size, to a maximum value, relative
## to the value of it's other axis.

#region Enums
## The behavior this node will exhibit based on an axis.
enum MAX_RATIO_MODE {
	NONE, ## No maximum value for either axis on this container.
	WIDTH, ## Sets and expands children height to be proportionate of width.
	WIDTH_PROPORTION, ## Sets the maximum height value of this container to be proportionate of width.
	HEIGHT, ## Sets and expands children width to be proportionate of height.
	HEIGHT_PROPORTION ## Sets the maximum width value of this container to be proportionate of height.
}
#endregion


#region External Variables
## The ratio mode used to expand and limit children.
@export var mode : MAX_RATIO_MODE = MAX_RATIO_MODE.NONE:
	set(val):
		if val != mode:
			mode = val
			queue_sort()
## The ratio value used to expand and limit children.
@export_range(0.001, 10, 0.001, "or_greater") var ratio : float = 1.0:
	set(val):
		if val != ratio:
			ratio = val
			queue_sort()
#endregion


#region Private Virtual Methods
func _init() -> void:
	clip_contents = false

func _get_minimum_size() -> Vector2:
	var parent := get_parent_area_size()
	var min_size := super()
	
	var current_size := min_size.max(size)
	match mode:
		MAX_RATIO_MODE.NONE:
			current_size = Vector2(0, 0)
		MAX_RATIO_MODE.WIDTH, MAX_RATIO_MODE.WIDTH_PROPORTION:
			current_size = Vector2(0, minf(current_size.x * ratio, parent.y))
		MAX_RATIO_MODE.HEIGHT, MAX_RATIO_MODE.HEIGHT_PROPORTION:
			current_size = Vector2(minf(current_size.y * ratio, parent.x), 0)
	
	min_size = min_size.max(current_size)
	return min_size

func _validate_property(property: Dictionary) -> void:
	if property.name in ["max_size", "clip_contents"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
#endregion


#region Custom Methods Overwriting
## Updates the _max_size according to the ratio mode and current dimentions
func _update_children() -> void:
	var parent := get_parent_area_size()
	var min_size := get_combined_minimum_size()
	
	# Adjusts max_size itself accouring to the ratio mode and current dimentions
	match mode:
		MAX_RATIO_MODE.NONE:
			_max_size = Vector2(-1, -1)
		MAX_RATIO_MODE.WIDTH:
			_max_size = Vector2(-1, minf(size.x * ratio, parent.y))
		MAX_RATIO_MODE.WIDTH_PROPORTION:
			_max_size = Vector2(-1, min(size.x * ratio, parent.y, min_size.y))
		MAX_RATIO_MODE.HEIGHT:
			_max_size = Vector2(minf(size.y * ratio, parent.x), -1)
		MAX_RATIO_MODE.HEIGHT_PROPORTION:
			_max_size = Vector2(min(size.y * ratio, parent.x, min_size.x), -1)
	
	var new_size := size
	if _max_size.x >= 0:
		new_size.x = _max_size.x
	if _max_size.y >= 0:
		new_size.y = _max_size.y
	set_deferred("size", new_size)
	
	super()
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
