@tool
class_name RouterSlidePageInfo extends Resource
## A [Resource] to share information between [BaseRouterSlideTab] nodes.


#region Signals
## Emitted when the page index is changed.
signal changed_page_idx(old_index : int, new_index : int)
## Emitted when the page scene changes.
signal changed_page_scene(index : int)
## Emitted when the tab's arguments changes.
signal changed_tabs_args
## Emitted when the tab's focus status changes.
signal changed_focus(use_animation : bool)
## Emitted when the tab's disable status changes.
signal changed_disabled(use_animation : bool)
#endregion


#region External Variables
## A [PackedScene] for a page. The root node must inhert from the [Page] class.
@export var page : PackedScene:
	set(val):
		if val != page:
			if val && !scene_is_page(val):
				return
			page = val
			
			changed.emit()
			changed_page_scene.emit(_page_idx)
## The individual argument for this tab. 
@export var tab_args : Dictionary = {}:
	set(val):
		if val != tab_args:
			tab_args = val
			
			changed.emit()
			changed_tabs_args.emit()
#endregion


#region Private Variables
var _disabled : bool
var _focused : bool

var _page_idx : int = -1:
	set = set_page_idx,
	get = get_page_idx

var _global_args : Dictionary:
	set(val):
		if val != _global_args:
			_global_args = val
			
			changed.emit()
			changed_tabs_args.emit()
#endregion



#region Static Methods
## Checks if the given [PackedScene] has a root node that inherts
## from class [Page].
static func scene_is_page(scene : PackedScene) -> bool:
	if !scene:
		return false
	
	var node : Node = scene.instantiate()
	if node is Page:
		node.free()
		return true
	node.free()
	return false
#endregion


#region Public Methods (State Accessor)
## Changes the disabled status of this tab.
func set_disabled(toggle : bool, use_animation : bool = false) -> void:
	if toggle != _disabled:
		_disabled = toggle
		
		changed.emit()
		changed_disabled.emit(use_animation)
## Changes the focus status of this tab.
func set_focused(toggle : bool, use_animation : bool = false) -> void:
	if toggle != _focused:
		_focused = toggle
		
		changed.emit()
		changed_focus.emit(use_animation)

## Returns if this tab should be disabled.
func is_disabled() -> bool:
	return _disabled
## Returns if this tab should be focused.
func is_focused() -> bool:
	return _focused
#endregion


#region Public Methods (Index)
## Changes the page index this tab refers to.
func set_page_idx(val : int) -> void:
	if val != _page_idx:
		changed.emit()
		changed_page_idx.emit(_page_idx, val)
		
		_page_idx = val
## Gets the page index this tab refers to.
func get_page_idx() -> int:
	return _page_idx
#endregion

#region Public Methods (Arguments)
## Returns the returns of [method get_tab_args] and [method get_global_args]
## merged together, with a priority to [method get_global_args].
func get_args() -> Dictionary:
	return _global_args.merged(tab_args)
## Returns [member tab_args].
func get_tab_args() -> Dictionary:
	return tab_args
## Returns the tab arguments of the parent [RouterSlide] node.
func get_global_args() -> Dictionary:
	return _global_args
#endregion
