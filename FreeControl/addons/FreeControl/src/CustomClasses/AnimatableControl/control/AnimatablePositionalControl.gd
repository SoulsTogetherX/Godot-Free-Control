# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatablePositionalControl extends AnimatableControl
## A container to be used for free transformation, within a UI, depended on a [ScrollContainer]'s scroll progress.


#region Public Methods
## Returns the node's realtive position on the scene.
func get_scene_position(with_offset : bool = true) -> Vector2:
	var pos := get_global_transform_with_canvas().get_origin()
	if with_offset:
		pos += pivot_offset
	
	return pos

## Returns the node's realtive position on the scene, as a percent.
## [br][br]
## [b]NOTE[/b]: Percentage can be negative.
func get_scene_position_percent(with_offset : bool = true) -> Vector2:
	var viewport := get_viewport()
	if !viewport:
		return Vector2.ZERO
	
	var visible_rect := viewport.get_visible_rect()
	return get_scene_position(with_offset) / visible_rect.size
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
