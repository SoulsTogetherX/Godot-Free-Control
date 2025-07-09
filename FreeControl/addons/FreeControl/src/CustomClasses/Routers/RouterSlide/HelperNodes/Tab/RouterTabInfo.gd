# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name RouterTabInfo extends Resource
## A [Resource] used to hold data for a tab. Ued by [RouterSlide].

#region External Variables
## A signal that is emited if the page changes.
## [br][br]
## Also see [member page].
signal page_changed
## A signal that is emited if the disabled status changes.
## [br][br]
## Also see [member disabled].
signal disabled_changed
## A signal that is emited if the arguments change.
## [br][br]
## Also see [member args].
signal arguments_changed
#endregion


#region External Variables
## A [PackedScene] for a page. The root node must inhert from the [Page] class.
@export var page : PackedScene:
	set(val):
		if page != val:
			if val != null:
				if scene_is_page(val):
					page = val
					
					changed.emit()
					page_changed.emit()
					return
				push_warning("Cannot use scenes, with root that does inhertant from 'Page', as a page for 'RouterSlide'.")
			page = null
			changed.emit()
			page_changed.emit()
## If [code]true[/code], this tab will be usable to be selected by user input.
@export var disabled : bool:
	set(val):
		if disabled != val:
			disabled = val
			
			changed.emit()
## The individual argument for this tab. 
@export var args : Dictionary:
	set(val):
		if args != val:
			args = val
			
			changed.emit()
			arguments_changed.emit()
#endregion


#region Static Methods
## Checks if the given [PackedScene] has a root node that inherts
## from class [Page].
static func scene_is_page(scene : PackedScene) -> bool:
	if !scene:
		return false
	
	var state : SceneState
	while true:
		state = scene.get_state()
		if state.get_node_type(0).is_empty():
			scene = scene._bundled.get("variants")[0]
			continue
		break
	
	var root_script_raw: Variant = state.get_node_property_value(
		0, state.get_node_property_count(0) - 1
	)
	
	if root_script_raw is GDScript:
		return root_script_raw.new() is Page
	return false
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
