# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableScrollControl extends AnimatableControl
## A container to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress.

#region External Variables
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
				
				if is_node_ready():
					_scrolled_horizontal(val.get_h_scroll_bar().value)
					_scrolled_vertical(val.get_v_scroll_bar().value)
#endregion


#region Private Virtual Methods
func _enter_tree() -> void:
	if !scroll && Engine.is_editor_hint(): scroll = get_parent_scroll()
#endregion


#region Custom Virtual Methods
## A virtual function that is called when [member scroll] is horizontally scrolled.
## [br][br]
## Paramter [param scroll] is the current horizontal progress of the scroll.
func _scrolled_horizontal(scroll_hor : float) -> void: pass
## A virtual function that is called when [member scroll] is vertically scrolled.
## [br][br]
## Paramter [param scroll] is the current vertical progress of the scroll.
func _scrolled_vertical(scroll_ver : float) -> void: pass
#endregion


#region Public Methods
## Returns the global difference between this node's [AnimatableMount] and
## [member scroll] positions.
func get_origin_offset() -> Vector2:
	var mount := get_mount()
	if !scroll || !mount:
		return Vector2.ZERO
	
	return mount.global_position - scroll.global_position 
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
	var mount := get_mount()
	if !scroll || !mount:
		return 0
	
	return (mount.get_global_rect().intersection(scroll.get_global_rect()).get_area()) / (mount.size.x * mount.size.y)
## Returns a percentage of how visible this node's [AnimatableMount] is, within the
## horizontal bounds of [member scroll].
func get_visible_horizontal_percent() -> float:
	var mount := get_mount()
	if !scroll || !mount:
		return 0
	
	return (min(mount.global_position.x + mount.size.x, scroll.global_position.x + scroll.size.x) - max(mount.global_position.x, scroll.global_position.x)) / mount.size.x
## Returns a percentage of how visible this node's [AnimatableMount] is, within the
## vertical bounds of [member scroll].
func get_visible_vertical_percent() -> float:
	var mount := get_mount()
	if !scroll || !mount:
		return 0
	
	return (min(mount.global_position.y + mount.size.y, scroll.global_position.y + scroll.size.y) - max(mount.global_position.y, scroll.global_position.y)) / mount.size.y
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
