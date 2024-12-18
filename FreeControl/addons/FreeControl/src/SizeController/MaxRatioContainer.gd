@tool
class_name MaxRatioContainer extends MaxSizeContainer

enum MAX_RATIO_CONTROL {
	NONE,
	WIDTH,
	WIDTH_PROPORTION,
	HEIGHT,
	HEIGHT_PROPORTION
}

@export var mode : MAX_RATIO_CONTROL = MAX_RATIO_CONTROL.NONE:
	set(val):
		if val != mode:
			mode = val
			_handle_resize()
@export_range(0.001, 10) var ratio : float = 1.0:
	set(val):
		val = max(0.001, val)
		if val != ratio:
			ratio = val
			_handle_resize()

func _validate_property(property: Dictionary) -> void:
	if property.name == "max_size":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func _before_resize_children() -> void:
	match mode:
		MAX_RATIO_CONTROL.WIDTH:
			_max_size = Vector2(-1, size.x * ratio)
		MAX_RATIO_CONTROL.WIDTH_PROPORTION:
			_max_size = Vector2(-1, minf(size.x * ratio, _get_children_minimum_size().y))
		MAX_RATIO_CONTROL.HEIGHT:
			_max_size = Vector2(size.y * ratio, -1)
		MAX_RATIO_CONTROL.HEIGHT_PROPORTION:
			_max_size = Vector2(minf(size.y * ratio, _get_children_minimum_size().x), -1)
	
	var newSize := size
	if _max_size.x >= 0:
		newSize.x = _max_size.x
	if _max_size.y >= 0:
		newSize.y = _max_size.y
	call_deferred("set_size", newSize)

func _get_minimum_size() -> Vector2:
	return _max_size
func _get_children_minimum_size() -> Vector2:
	var min_size : Vector2 = Vector2.ZERO
	for child in get_children():
		if child is Control:
			var child_min : Vector2 = child.get_combined_minimum_size()
			min_size = min_size.max(child_min)
	return min_size
