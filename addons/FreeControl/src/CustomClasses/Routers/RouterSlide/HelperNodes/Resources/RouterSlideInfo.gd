@tool
class_name RouterSlideInfo extends Resource
## A [Resource] to share information between all parts of a [RouterSlide].


#region Signals
## Emitted when [member page_infos] size changes
signal changed_size
## Emitted when [member tab_template] changes
signal changed_tabs_template
## Emitted when [member global_tab_args] changes
signal changed_tabs_args
## Emitted when [member page_load_mode] is changed.
signal changed_load_mode
## Emitted when [member page_hide_mode] is changed.
signal changed_hide_mode
## Emitted when the page index changes
signal changed_idx(old_idx : int, new_idx : int, use_animation : bool)
#endregion


#region Enums
## An Enum related to how this node will lazy-initiated [Page]s.
enum PAGE_LOAD_MODE {
	ON_DEMAND, ## Will initiated only the [Page] being animated to.
	ON_DEMAND_BRIDGE, ## Will initiated all [Page]s between the current [Page] and the [Page] being animated to.
	ALL ## All [Page]s are initiated immediately
}

## An Enum related to how this node will hide already initiated [Page]s that
## are outside of visible space.
enum PAGE_HIDE_MODE {
	NONE, ## Nothing.
	HIDE, ## Will hide [Page] nodes outside of visible space.
	DISABLE, ## Will disable process_mode of [Page] nodes outside of visible space.
	HIDE_DISABLE, ## A combination of [const PAGE_HIDE_MODE.HIDE] and [const PAGE_HIDE_MODE.DISABLE].
	UNLOAD ## Will uninitiated [Page] nodes outside of visible space.
}
#endregion


#region External Variables
## Allows animations to play while in the Editor
@export var animate_in_engine : bool = false

@export_subgroup("Page Info")
## The info related to the pages allowing selection.
## [br][br]
## Also see: [signal changed_size].
@export var page_infos : Array[RouterSlidePageInfo]:
	set(val):
		if val != page_infos:
			var old_len := page_infos.size()
			
			for i : int in val.size():
				if !val[i]:
					val[i] = RouterSlidePageInfo.new()
				val[i].set_page_idx(i)
			page_infos = val
			
			changed.emit()
			if val.size() != old_len:
				changed_size.emit()
				set_index(clamp_idx(_idx), false)
## The current page index.
@export var index : int:
	set(val):
		set_index(clamp_idx(val), animate_in_engine)
	get:
		return _idx

@export_subgroup("Page Loading")
## Controls how this node will lazy-initiated [Page]s.
## [br][br]
## Also see: [signal changed_load_mode].
@export var page_load_mode : PAGE_LOAD_MODE = PAGE_LOAD_MODE.ON_DEMAND_BRIDGE:
	set(val):
		if val != page_load_mode:
			page_load_mode = val
			
			changed.emit()
			changed_load_mode.emit()
## Controls how this node will hide already initiated [Page]s that are
## outside of visible space.
## [br][br]
## [b]NOTE:[/b] The value [constant PAGE_HIDE_MODE.UNLOAD] is treated the
## same as [constant PAGE_HIDE_MODE.NONE] if [member page_load_mode] is
## [constant PAGE_LOAD_MODE.ALL].
## [br][br]
## Also see: [signal changed_hide_mode].
@export var page_hide_mode : PAGE_HIDE_MODE = PAGE_HIDE_MODE.HIDE:
	set(val):
		if val != page_hide_mode:
			page_hide_mode = val
			
			changed.emit()
			changed_hide_mode.emit()

@export_group("Tab Info")
## The scene template each tab will use. The given [PackedScene] must have a root
## [Node] tht extends from the [BaseRouterTab] class.
## [br][br]
## Also see: [signal changed_tabs_template].
@export var tab_template : PackedScene:
	set(val):
		if val != tab_template:
			if val && !scene_is_tab(val):
				return
			tab_template = val
			
			changed.emit()
			changed_tabs_template.emit()
## Global Arguments for all tabs. Will be overwriten by any direct arguments given
## to tabs.
## [br][br]
## Also see: [signal changed_tabs_args].
@export var global_tab_args : Dictionary = {}: #Share by reference
	set(val):
		if val != global_tab_args:
			global_tab_args = val
			
			changed.emit()
			changed_tabs_args.emit()
#endregion


#region Private Variables
var _idx : int = -1
#endregion



#region Static Methods
## Checks if the given [PackedScene] has a root node that inherts
## from class [Page].
static func scene_is_tab(scene : PackedScene) -> bool:
	if scene == null:
		return false
	
	var node : Node = scene.instantiate()
	if node is BaseRouterSlideTab:
		node.free()
		return true
	node.free()
	return false
#endregion


#region Public Methods (Index)
## Clamps the given [param idx] to a vaild number. If [member page_infos]
## is empty, then this returns [code]-1[/code].
func clamp_idx(idx : int) -> int:
	return mini(maxi(idx, 0), page_infos.size() - 1)
## Returns if the given [param idx] is vaild.
## [br][br]
## Also see [member page_infos].
func is_vaild_idx(idx : int) -> bool:
	return 0 <= idx && idx < page_infos.size()

## Sets the current page index.
## [br][br]
## Also see: [signal changed_idx].
func set_index(idx : int, use_animation : bool = true) -> void:
	idx = clamp_idx(idx)
	if _idx != idx:
		# Swap values
		_idx ^= idx 
		idx ^= _idx 
		_idx ^= idx
		
		changed_idx.emit(idx, _idx, use_animation)
## Gets the current page index.
func get_index() -> int:
	return _idx
#endregion


#region Public Methods (Helper)
## [br][br]
## Also see: [signal changed_size].
func is_empty() -> bool:
	return page_infos.is_empty()
## [br][br]
## Also see: [signal changed_size].
func size() -> int:
	return page_infos.size()
#endregion
