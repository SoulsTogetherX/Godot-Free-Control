# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableScrollControl extends AnimatableControl
## A container to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress.

## The [ScrollContainer] this node will consider for operations. Is automatically
## set to the closet parent [ScrollContainer] in the tree if [member scroll] is
## [code]null[/code] and [Engine] is in editor mode.
## [br][br]
## [b]NOTE[/b]: It is recomended that this node's [AnimatableMount] is a child of
## [member scroll].
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
				
				_scrolled_horizontal(val.get_h_scroll_bar().value)
				_scrolled_vertical(val.get_v_scroll_bar().value)

## A virtual function that is called when [member scroll] is horizontally scrolled.
## [br][br]
## Paramter [param scroll] is the current horizontal progress of the scroll.
func _scrolled_horizontal(scroll_hor : float) -> void: pass
## A virtual function that is called when [member scroll] is vertically scrolled.
## [br][br]
## Paramter [param scroll] is the current vertical progress of the scroll.
func _scrolled_vertical(scroll_ver : float) -> void: pass

## Returns the global difference between this node's [AnimatableMount] and
## [member scroll] positions.
func get_origin_offset() -> Vector2:
	if !_mount || !scroll: return Vector2.ZERO
	return _mount.global_position - scroll.global_position 
## Returns the horizontal and vertical progress of [member scroll].
func get_scroll_offset() -> Vector2:
	if !scroll: return Vector2.ZERO
	return Vector2(scroll.scroll_horizontal, scroll.scroll_vertical)
## Gets the closet parent [ScrollContainer] in the tree.
func get_parent_scroll() -> ScrollContainer:
	var ret : Control = (get_parent() as Control)
	while ret != null:
		if ret is ScrollContainer: return ret
		ret = (ret.get_parent() as Control)
	return null

## Returns a percentage of how visible this node's [AnimatableMount] is, within
## the rect of [member scroll].
func is_visible_percent() -> float:
	if !_mount || !scroll: return 0
	return (_mount.get_global_rect().intersection(scroll.get_global_rect()).get_area()) / (_mount.size.x * _mount.size.y)
## Returns a percentage of how visible this node's [AnimatableMount] is, within the
## horizontal bounds of [member scroll].
func get_visible_horizontal_percent() -> float:
	if !_mount || !scroll: return 0
	return (min(_mount.global_position.x + _mount.size.x, scroll.global_position.x + scroll.size.x) - max(_mount.global_position.x, scroll.global_position.x)) / _mount.size.x
## Returns a percentage of how visible this node's [AnimatableMount] is, within the
## vertical bounds of [member scroll].
func get_visible_vertical_percent() -> float:
	if !_mount || !scroll: return 0
	return (min(_mount.global_position.y + _mount.size.y, scroll.global_position.y + scroll.size.y) - max(_mount.global_position.y, scroll.global_position.y)) / _mount.size.y

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
