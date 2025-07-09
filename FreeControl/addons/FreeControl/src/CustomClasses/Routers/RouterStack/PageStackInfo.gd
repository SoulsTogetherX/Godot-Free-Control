# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name PageStackInfo extends Resource
## A [Resource] for keeping stack of [Page] information for a Router, such as [RouterStack].

#region Private Variables
var _page : Control
var _auto_clean : bool
var _enter_animate : SwapContainer.ANIMATION_TYPE
var _exit_animate : SwapContainer.ANIMATION_TYPE
#endregion


#region Static Methods
## Static create function for this [Resource].
static func create(
	page: Page,
	enter_animate : SwapContainer.ANIMATION_TYPE,
	exit_animate : SwapContainer.ANIMATION_TYPE,
	auto_clean : bool
) -> PageStackInfo:
	page.clip_contents = true
	
	var info = PageStackInfo.new()
	info._page = page
	info._enter_animate = enter_animate
	info._exit_animate = exit_animate
	info._auto_clean = auto_clean
	
	return info
#endregion


#region Private Virtual Methods
func _notification(what):
	if (
		what == NOTIFICATION_PREDELETE &&
		_auto_clean &&
		_page &&
		is_instance_valid(_page)
	):
		_page.queue_free()
		_page = null
#endregion


#region Public Methods
## Gets the current [Page] held by this [Resource].
func get_page() -> Page:
	return _page
## Gets the saved enter animation.
func get_enter_animation() -> SwapContainer.ANIMATION_TYPE:
	return _enter_animate
## Gets the saved exit animation.
func get_exit_animation() -> SwapContainer.ANIMATION_TYPE:
	return _exit_animate
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
