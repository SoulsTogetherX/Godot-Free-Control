# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name DistanceCheck extends MotionCheck
## A [Control] node used to check if a mouse or touch moved a distance away from where
## the user originally pressed.

#region Enums
## How this node will determine the distance between the starting and current location
## of mouse and touch movement.
enum CHECK_MODE {
	NONE = 0b000, ## No action.
	HORIZONTAL = 0b001, ## Only checks the horizontal difference.
	VERTICAL = 0b010, ## Only checks the vertical difference.
	BOTH = 0b011, ## Only checks orthogonal difference.
	DISTANCE = 0b100 ## Uses the Pythagorean Theorem.
}
#endregion


#region External Variables
## The current check mode.
##
## Also see [enum CHECK_MODE].
@export var mode : CHECK_MODE
## The max pixels difference, between the start and current position, that can be tolerated.
@export_range(0, 500, 0.001, "or_greater", "suffix:px") var distance : float = 30
#endregion


#region Private Variables
var _prev_pos : Vector2
#endregion


#region Custom Methods Overwriting
func _pos_check(pos : Vector2) -> bool:
	if mode & CHECK_MODE.DISTANCE:
		if _prev_pos.distance_squared_to(pos) > distance * distance:
			return false
		return true
	
	var diff := (_prev_pos - pos).abs()
	if mode & CHECK_MODE.HORIZONTAL:
		if diff.x > distance:
			return false
	if mode & CHECK_MODE.VERTICAL:
		if diff.y > distance:
			return false
	return true
func _on_check_start(event: InputEvent) -> void:
	_prev_pos = event.position
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
