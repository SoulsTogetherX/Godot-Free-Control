@tool
class_name PageInfo extends Resource
## Holds all relevant page information for a router to use. 

var _page : Control
var _auto_clean : bool
var _enter_animate : SwapContainer.ANIMATION_TYPE
var _exit_animate : SwapContainer.ANIMATION_TYPE


## Returns the current [Page] node.
func get_page() -> Page: return _page
## Returns the assigned enter animation.
func get_enter_animation() -> SwapContainer.ANIMATION_TYPE: return _enter_animate
## Returns the assigned exit animation.
func get_exit_animation() -> SwapContainer.ANIMATION_TYPE: return _exit_animate



func _init(
	page: Page,
	enter_animate : SwapContainer.ANIMATION_TYPE,
	exit_animate : SwapContainer.ANIMATION_TYPE,
	auto_clean : bool
) -> void:
	_page = page
	_enter_animate = enter_animate
	_exit_animate = exit_animate
	_auto_clean = auto_clean

# Auto frees the [Page] nocde if this resource is cleared.
func _notification(what):
	if (
		what == NOTIFICATION_PREDELETE &&
		_auto_clean &&
		_page &&
		is_instance_valid(_page)
	):
		_page.queue_free()
		_page = null
