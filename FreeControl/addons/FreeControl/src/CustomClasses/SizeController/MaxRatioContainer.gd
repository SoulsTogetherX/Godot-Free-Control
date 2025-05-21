# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxRatioContainer extends MaxSizeContainer
## A container that limits an axis of it's size, to a maximum value, relative
## to the value of it's other axis.

## The behavior this node will exhibit based on an axis.
enum MAX_RATIO_MODE {
	NONE, ## No maximum value for either axis on this container.
	WIDTH, ## Sets and expands children height to be proportionate of width.
	WIDTH_PROPORTION, ## Sets the maximum height value of this container to be proportionate of width.
	HEIGHT, ## Sets and expands children width to be proportionate of height.
	HEIGHT_PROPORTION ## Sets the maximum width value of this container to be proportionate of height.
}

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



func _validate_property(property: Dictionary) -> void:
	if property.name == "max_size":
		property.usage |= PROPERTY_USAGE_READ_ONLY

## Updates the _max_size according to the ratio mode and current dimentions
func _update_childrend() -> void:
	var parent := get_parent_area_size()
	var min_size := get_combined_minimum_size()
	
	# Adjusts max_size itself accouring to the ratio mode and current dimentions
	match mode:
		MAX_RATIO_MODE.NONE:
			max_size = Vector2(-1, -1)
		MAX_RATIO_MODE.WIDTH:
			max_size = Vector2(-1, minf(size.x * ratio, parent.y))
		MAX_RATIO_MODE.WIDTH_PROPORTION:
			max_size = Vector2(-1, min(size.x * ratio, min_size.y, parent.y))
		MAX_RATIO_MODE.HEIGHT:
			max_size = Vector2(minf(size.y * ratio, parent.x), -1)
		MAX_RATIO_MODE.HEIGHT_PROPORTION:
			max_size = Vector2(min(size.y * ratio, min_size.x, parent.x), -1)
	
	var newSize := size
	if max_size.x >= 0:
		newSize.x = max_size.x
	if max_size.y >= 0:
		newSize.y = max_size.y
	size = newSize.max(min_size)
	
	super()

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
