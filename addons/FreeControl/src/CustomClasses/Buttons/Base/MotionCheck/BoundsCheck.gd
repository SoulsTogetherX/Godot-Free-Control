# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name BoundsCheck extends MotionCheck
## A [Control] node used to check if a mouse or touch moved outside this node's bounds after
## a vaild press inside.

#region Custom Methods Overwriting
func _pos_check(pos : Vector2) -> bool:
	return get_global_rect().has_point(pos)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
