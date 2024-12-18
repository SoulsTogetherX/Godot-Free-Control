@tool
class_name AnimatableScrollControl extends AnimatableControl
## A [Control] to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress

## The [ScrollContainer] this node will consider for operations
## [br][br]
## [b]NOTE[/b]: It is recomended that this node's [AnimatableMount] is a child of [member scroll]
@export var scroll : ScrollContainer:
	set(val):
		if scroll != val:
			if scroll:
				scroll.get_h_scroll_bar().value_changed.disconnect(_scrolled_horizontal)
				scroll.get_v_scroll_bar().value_changed.disconnect(_scrolled_vertical)
			scroll = val
			if val:
				val.get_h_scroll_bar().value_changed.connect(_scrolled_horizontal)
				val.get_v_scroll_bar().value_changed.connect(_scrolled_vertical)

## An abstract function that is called when [member scroll] is horizontally scrolled
## [br][br]
## Paramter [param scroll] is the current horizontal progress of the scroll
func _scrolled_horizontal(scroll : float) -> void:
	push_warning("Abstract method '_scrolled_horizontal' called without overloading")
## An abstract function that is called when [member scroll] is vertically scrolled
## [br][br]
## Paramter [param scroll] is the current vertical progress of the scroll
func _scrolled_vertical(scroll : float) -> void:
	push_warning("Abstract method '_scrolled_vertical' called without overloading")

## Returns the global difference between this node's [AnimatableMount] and [member scroll] positions
func get_origin_offset() -> Vector2:
	if !_mount || !scroll: return Vector2.ZERO
	return _mount.global_position - scroll.global_position 
## Returns the horizontal and vertical progress of [member scroll]
func get_scroll_offset() -> Vector2:
	if !scroll: return Vector2.ZERO
	return Vector2(scroll.scroll_horizontal, scroll.scroll_vertical)

## Returns a percentage of how visible this node's [AnimatableMount] is, within the rect of [member scroll]
func is_visible_percent() -> float:
	if !_mount || !scroll: return 0
	return (_mount.get_global_rect().intersection(scroll.get_global_rect()).get_area()) / (scroll.size.x * scroll.size.y)
## Returns a percentage of how visible this node's [AnimatableMount] is, within the horizontal bounds of [member scroll]
func get_visible_horizontal_percent() -> float:
	if !_mount || !scroll: return 0
	return (min(_mount.global_position.x + _mount.size.x, scroll.global_position.x + scroll.size.x) - max(_mount.global_position.x, scroll.global_position.x)) / scroll.size.x
## Returns a percentage of how visible this node's [AnimatableMount] is, within the vertical bounds of [member scroll]
func get_visible_vertical_percent() -> float:
	if !_mount || !scroll: return 0
	return (min(_mount.global_position.y + _mount.size.y, scroll.global_position.y + scroll.size.y) -  max(_mount.global_position.y, scroll.global_position.y)) / scroll.size.y
