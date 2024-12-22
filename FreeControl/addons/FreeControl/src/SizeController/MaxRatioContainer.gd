# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name MaxRatioContainer extends MaxSizeContainer
## A container that limits an axis of it's size, to a maximum value, relative to the value of it's other axis.

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
			_handle_resize()
## The ratio value used to expand and limit children.
@export_range(0.001, 10, 0.001, "or_greater") var ratio : float = 1.0:
	set(val):
		if val != ratio:
			ratio = val
			_handle_resize()

func _validate_property(property: Dictionary) -> void:
	if property.name == "max_size":
		property.usage |= PROPERTY_USAGE_READ_ONLY
func _get_minimum_size() -> Vector2:
	return _max_size
func _get_children_minimum_size() -> Vector2:
	var min_size : Vector2 = Vector2.ZERO
	for child in get_children():
		if child is Control:
			var child_min : Vector2 = child.get_combined_minimum_size()
			min_size = min_size.max(child_min)
	return min_size

## Updates the _max_size according to the ratio mode and current dimentions
func _before_resize_children() -> void:
	# Adjusts max_size itself accouring to the ratio mode and current dimentions
	match mode:
		MAX_RATIO_MODE.NONE:
			_max_size = Vector2(-1, -1)
		MAX_RATIO_MODE.WIDTH:
			_max_size = Vector2(-1, size.x * ratio)
		MAX_RATIO_MODE.WIDTH_PROPORTION:
			_max_size = Vector2(-1, minf(size.x * ratio, _get_children_minimum_size().y))
		MAX_RATIO_MODE.HEIGHT:
			_max_size = Vector2(size.y * ratio, -1)
		MAX_RATIO_MODE.HEIGHT_PROPORTION:
			_max_size = Vector2(minf(size.y * ratio, _get_children_minimum_size().x), -1)
	
	var newSize := size
	if _max_size.x >= 0:
		newSize.x = _max_size.x
	if _max_size.y >= 0:
		newSize.y = _max_size.y
	size = newSize

# Made by Savier Alvarez. A part of the "FreeControl" Godot addon.
