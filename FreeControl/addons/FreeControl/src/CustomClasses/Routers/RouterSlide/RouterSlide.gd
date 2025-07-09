# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name RouterSlide extends Container
## Handles a [Control] slider, of [Page] nodes.

#region Signals
## Emits when the current [Page] requests an event.
signal event_action(event : String, args : Variant)

## Emits at the start of a page transition.
signal start_transition_page
## Emits at the end of a page transition.
signal end_transition_page

## Emits at the start of a highlight transition.
signal start_transition_highlight
## Emits at the end of a highlight transition.
signal end_transition_highlight
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

@export_group("Page Info")
## The info related to the pages allowing selection.
@export var pages : Array[RouterTabInfo] = []:
	set(val):
		if pages != val:
			pages = val
			
			for idx : int in pages.size():
				if !pages[idx]:
					pages[idx] = RouterTabInfo.new()
			
			start_page = clampi(start_page, 0, pages.size() - 1)
			
			_update_pages()
## The page that this node will start on after [method Node._init].
@export var start_page : int:
	set(val):
		val = clampi(val, 0, pages.size() - 1)
		
		if start_page != val:
			start_page = val
			
			if Engine.is_editor_hint() && is_node_ready():
				goto_page(val, true)
@export_subgroup("Page Loading")
## Controls how this node will lazy-initiated [Page]s.
@export var page_load_mode : PAGE_LOAD_MODE = PAGE_LOAD_MODE.ON_DEMAND:
	set(val):
		if page_load_mode != val:
			page_load_mode = val
			
			if is_node_ready():
				_page_container.load_mode = page_load_mode
## Controls how this node will hide already initiated [Page]s that are
## outside of visible space.
@export var page_hide_mode : PAGE_HIDE_MODE = PAGE_HIDE_MODE.HIDE:
	set(val):
		if page_hide_mode != val:
			page_hide_mode = val
			
			if is_node_ready():
				_page_container.hide_mode = page_hide_mode


@export_group("Scene Layout")
## If [code]true[/code], tabs will be placed at the top of the node.
## Otherwise, they will be placed at the bottom.
@export var tabs_top : bool = false:
	set(val):
		if tabs_top != val:
			tabs_top = val
			
			_init_shadow_style()
			_position_components()
## The height of the tabs in pixels.
@export var tab_height : float = 70:
	set(val):
		tab_height = max(0, tab_height)
		
		if tab_height != val:
			tab_height = val
			
			_position_components()
## The local z_index the tabs bar will have, from this node.
## Value can only be positive.
@export_range(0, 4096) var tab_z_index : int:
	set(val):
		tab_z_index = clampi(tab_z_index, 0, 4096)
		if tab_z_index != val:
			tab_z_index = val
			
			_tab_background.z_index = tab_z_index


@export_group("Tab Layout")
## The scene template each tab will use. The given [PackedScene] must have a root
## [Node] tht extends from the [BaseRouterTab] class.
@export var tab_scene : PackedScene:
	set(val):
		if tab_scene != val:
			if val != null:
				if scene_is_tab(val):
					tab_scene = val
					
					_refresh_tabs()
					return
				push_warning("Cannot use scenes, with root that does inhertant from 'BaseRouterTab', as a tab template.")
			tab_scene = null
			_refresh_tabs()
## Global Arguments for all tabs. Will be overwriten by any direct arguments given
## to tabs.
@export var tab_args : Dictionary:
	set(val):
		if tab_args != val:
			tab_args = val
			
			_tab_container.set_args(tab_args)

@export_subgroup("Tab Shadow")
## The height of the shadow emits from the tabs.
@export var shadow_height : float = 0:
	set(val):
		shadow_height = max(0, shadow_height)
		
		if shadow_height != val:
			shadow_height = val
			
			_shadow.visible = is_shadow_visible()
			_position_components()
## The gradient of the shadow emited from the tabs.
@export var shadow_gradient : Gradient:
	set(val):
		if shadow_gradient != val:
			shadow_gradient = val
			
			_shadow.visible = is_shadow_visible()

@export_subgroup("Tab Margins")
## The left margin of all tabs.
@export var margin_tab_left : int = 0:
	set(val):
		if margin_tab_left != val:
			margin_tab_left = val
			
			_queue_update_tab_margins()
## The top margin of all tabs.
@export var margin_tab_top : int = 0:
	set(val):
		if margin_tab_top != val:
			margin_tab_top = val
			
			_queue_update_tab_margins()
## The right margin of all tabs.
@export var margin_tab_right : int = 0:
	set(val):
		if margin_tab_right != val:
			margin_tab_right = val
			
			_queue_update_tab_margins()
## The bottom margin of all tabs.
@export var margin_tab_bottom : int = 0:
	set(val):
		if margin_tab_bottom != val:
			margin_tab_bottom = val
			
			_queue_update_tab_margins()


@export_group("Highlight Layout")
## If [code]true[/code], display a highlight near the tabs. Otherwise don't.
@export var include_highlight : bool = true:
	set(val):
		if include_highlight != val:
			include_highlight = val
			
			_highlight_container.visible = is_highlight_visible()
			_position_components()
## If [code]true[/code], the highlight will be displayed above the tabs. Otherwise,
## it will be displayed below the tab's bottom.
@export var top_highlight : bool = true:
	set(val):
		if top_highlight != val:
			top_highlight = val
			
			_position_components()
## If [code]true[/code], the tab background will extend to cover the highlight.
## Otherwise, the highlight will extend past the tab background.
@export var inset_highlight : bool = false:
	set(val):
		if inset_highlight != val:
			inset_highlight = val
			
			_position_components()
## Height of the highlight
@export var highlight_height : float = 3:
	set(val):
		if highlight_height != val:
			highlight_height = val
			
			_highlight_container.visible = is_highlight_visible()
			_position_components()
## Color of the highlight
@export var highlight_color : Color = Color(0.608, 0.329, 0.808):
	set(val):
		if highlight_color != val:
			highlight_color = val
			
			_highlight_container.set_color(highlight_color)


@export_group("Background")
## If [code]true[/code], [member bg_style] will be displayed under the
## [member tab_bg_style] too.
@export var bg_include_tabs : bool = false:
	set(val):
		if bg_include_tabs != val:
			bg_include_tabs = val
			
			_position_components()
## Background style for the [Page] nodes.
@export var bg_style : StyleBox:
	set(val):
		if bg_style != val:
			bg_style = val
			
			_background.visible = is_page_background_visible()
			if _background.visible:
				_background.add_theme_stylebox_override("panel", bg_style)
## Background style for the tab nodes.
## [br][br]
## Also see [member tab_scene].
@export var tab_bg_style : StyleBox:
	set(val):
		if tab_bg_style != val:
			tab_bg_style = val
			
			_tab_background.visible = is_tab_background_visible()
			if _tab_background.visible:
				_tab_background.add_theme_stylebox_override("panel", tab_bg_style)


@export_group("Animations")
@export_subgroup("Page")
## Length of time for this [Node] to swap [Page]s.
@export var page_speed : float = 0.4:
	set(val):
		if page_speed != val:
			page_speed = val
			
			_page_container.page_speed = page_speed
## The [enum Tween.EaseType] for [Page] animation.
@export var page_ease : Tween.EaseType = Tween.EASE_IN_OUT:
	set(val):
		if page_ease != val:
			page_ease = val
			
			_page_container.page_ease = page_ease
## The [enum Tween.TransitionType] for [Page] animation.
@export var page_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		if page_trans != val:
			page_trans = val
			
			_page_container.page_trans = page_trans

@export_subgroup("Highlight")
## Length of time for the highlight to animate.
@export var highlight_speed : float = 0.4:
	set(val):
		if highlight_speed != val:
			highlight_speed = val
			
			_highlight_container.animation_speed = highlight_speed
## The [enum Tween.EaseType] for highlight animation.
@export var highlight_ease : Tween.EaseType = Tween.EASE_OUT:
	set(val):
		if highlight_ease != val:
			highlight_ease = val
			
			_highlight_container.animation_ease = highlight_ease
## The [enum Tween.TransitionType] for highlight animation.
@export var highlight_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		if highlight_trans != val:
			highlight_trans = val
			
			_highlight_container.animation_trans = highlight_trans
#endregion


#region Private Variables
var _page_container  : Container
var _tab_container : Container
var _highlight_container : Container
var _tab_background : Panel
var _background : Panel
var _shadow : Panel

var _selected_index : int = -1

var _tab_margins_update_queued : bool
#endregion


#region Private Virtual Methods
func _init() -> void:
	_page_container = load("res://addons/FreeControl/src/CustomClasses/Routers/RouterSlide/HelperNodes/Containers/RouterSlide_PageContainer.gd").new()
	_background = Panel.new()
	_shadow = Panel.new()
	
	_tab_background = Panel.new()
	_tab_container = load("res://addons/FreeControl/src/CustomClasses/Routers/RouterSlide/HelperNodes/Containers/RouterSlide_TabContainer.gd").new()
	_highlight_container = load("res://addons/FreeControl/src/CustomClasses/Routers/RouterSlide/HelperNodes/Containers/RouterSlide_HighlightContainer.gd").new()
	
	add_child(_background)
	add_child(_page_container)
	add_child(_shadow)
	
	add_child(_tab_background)
	_tab_background.add_child(_tab_container)
	_tab_background.add_child(_highlight_container)
	
	_tab_container.tab_pressed.connect(goto_page.bind(true))
	_page_container.event_action.connect(event_action.emit)
	
	_page_container.start_transition.connect(start_transition_page.emit)
	_page_container.end_transition.connect(end_transition_page.emit)
	
	_highlight_container.start_transition.connect(start_transition_highlight.emit)
	_highlight_container.end_transition.connect(end_transition_highlight.emit)
	
	_init_components()

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY:
			_on_ready()
		NOTIFICATION_SORT_CHILDREN:
			_position_components()
#endregion


#region Static Methods
## Checks if the given [PackedScene] has a root node that inherts
## from class [BaseRouterTab].
static func scene_is_tab(scene : PackedScene) -> bool:
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
		return root_script_raw.is_tool() && root_script_raw.new() is BaseRouterTab
	return false
#endregion


#region Private Methods
func _position_components() -> void:
	# Sizes
	_tab_container.size = Vector2(size.x, tab_height).max(_tab_container.get_combined_minimum_size())
	_highlight_container.size = Vector2(size.x, highlight_height if include_highlight else 0)
	_tab_background.size = Vector2(size.x, _tab_container.size.y + (_highlight_container.size.y if inset_highlight else 0))
	_page_container.size = Vector2(size.x, size.y - _tab_background.size.y)
	
	_background.size = Vector2(size.x, size.y - (0 if bg_include_tabs else _tab_container.size.y))
	_shadow.size = Vector2(size.x, shadow_height)
	
	# Tab Compoents Positions
	if top_highlight:
		if inset_highlight:
			_highlight_container.position = Vector2.ZERO
			_tab_container.position = Vector2(0, _highlight_container.size.y)
		else:
			_highlight_container.position = Vector2(0, -_highlight_container.size.y)
			_tab_container.position = Vector2.ZERO
	else:
		_highlight_container.position = Vector2(0, _tab_container.size.y)
		_tab_container.position = Vector2.ZERO
	
	# Compoents Positions
	if tabs_top:
		_tab_background.position = Vector2.ZERO
		
		_page_container.position = Vector2(0, _tab_background.size.y)
		_background.position = Vector2.ZERO if bg_include_tabs else _page_container.position
		_shadow.position = _page_container.position
	else:
		_tab_background.position = Vector2(0, _page_container.size.y)
		_shadow.position = _tab_background.position
		_shadow.position.y -= _shadow.size.y
		
		_page_container.position = Vector2.ZERO
		_background.position = _page_container.position


func _queue_update_tab_margins() -> void:
	if _tab_margins_update_queued:
		return
	
	call_deferred("_update_tab_margins")
	_tab_margins_update_queued = true
func _update_tab_margins() -> void:
	_tab_container.set_margins(
		margin_tab_left,
		margin_tab_top,
		margin_tab_right,
		margin_tab_bottom
	)
	_tab_margins_update_queued = false


func _init_components() -> void:
	_init_shadow_style()
	_page_container.inital_pages(pages, start_page)
	_refresh_tabs()
	
	if is_node_ready():
		goto_page(start_page, false)


func _update_pages() -> void:
	_highlight_container.tab_number = pages.size()
	_page_container.inital_pages(pages, start_page)
	_refresh_tabs()



func _on_ready() -> void:
	_ready_highlight_container()
	_ready_page_container()
	_ready_tabs_container()
	_ready_background()
	_refresh_tabs()
func _ready_highlight_container() -> void:
	_highlight_container.set_color(highlight_color)
	
	_highlight_container.animation_speed = highlight_speed
	_highlight_container.animation_ease = highlight_ease
	_highlight_container.animation_trans = highlight_trans
	
	_highlight_container.tab_number = pages.size()
func _ready_page_container() -> void:
	_page_container.inital_pages(pages, start_page)
	
	_page_container.load_mode = page_load_mode
	_page_container.hide_mode = page_hide_mode
	
	_page_container.page_speed = page_speed
	_page_container.page_ease = page_ease
	_page_container.page_trans = page_trans
func _ready_tabs_container() -> void:
	_tab_background.z_index = tab_z_index
func _ready_background() -> void:
	_background.visible = is_page_background_visible()
	if _background.visible:
		_background.add_theme_stylebox_override("panel", bg_style)
	_tab_background.visible = is_tab_background_visible()
	if _tab_background.visible:
		_tab_background.add_theme_stylebox_override("panel", tab_bg_style)
	
	_init_shadow_style()

func _refresh_tabs() -> void:
	if !is_node_ready():
		return
	
	_tab_container.refresh_tabs(
		pages,
		tab_scene,
		tab_args,
		margin_tab_left,
		margin_tab_top,
		margin_tab_right,
		margin_tab_bottom
	)
	goto_page(start_page, false)


func _init_shadow_style() -> void:
	var shadow_style : StyleBoxTexture = (_shadow.get_theme_stylebox("panel") as StyleBoxTexture)
	if !shadow_style:
		shadow_style = StyleBoxTexture.new()
		shadow_style.texture = GradientTexture2D.new()
		_shadow.add_theme_stylebox_override("panel", shadow_style)
	
	shadow_style.texture.gradient = shadow_gradient
	shadow_style.texture.fill_to = Vector2(0, int(tabs_top))
	shadow_style.texture.fill_from = Vector2(0, 1 - int(tabs_top))
#endregion


#region Public Methods
## Sets the current [Page] to the given vaild index.
## [br][br]
## The [param idx] is clamped to a vaild index. If [code]animate[/code] is true
## the node will animated the transition between pages. 
func goto_page(idx : int, animate : bool) -> void:
	animate = animate && (!Engine.is_editor_hint() || animate_in_engine)
	_selected_index = idx
	
	_highlight_container.goto_index(idx, animate)
	_tab_container.goto_index(idx, animate)
	_page_container.goto_index(idx, animate)

## Toggle if a tab is disabled or not. If so, then the user will not be able to select
## it.
## [br][br]
## Invaild [param idx] indexes are ignored. If [code]animate[/code] is true
## the node will animated the transition between pages. 
## [br][br]
## [b]NOTE[/b]: [method goto_page] will still work for the disabled tab.
func toggle_disable(idx : int, disable : bool, animate : bool = true) -> void:
	_tab_container.toggle_disable(idx, disable, animate)

## Return the size of the page container.
func get_page_size() -> Vector2:
	return _page_container.size
## Return the size of the tab container.
func get_tabs_size() -> Vector2:
	return _tab_container.size
## Return the index of the currently selected page.
func get_current_page() -> int:
	return _selected_index
## Returns the indexes of all currently visible pages.
## [br][br]
## [b]NOTE[/b]: Multiple pages can be visible during animations.
func get_visible_pages() -> Array[int]:
	return _page_container.get_visible_pages()

## Returns the [Page] node associated with given [param idx].
## [br][br]
## [b]Warning[/b]: This is a required internal node, removing and freeing it
## may cause a crash.
func get_page_node(idx : int) -> Page:
	return _page_container.get_page_node(idx)

## Emits the [Signal Page.entered] signal in the current [Page].
func emit_entered() -> void:
	_page_container.emit_entered()
## Emits the [Signal Page.entering] signal in the current [Page].
func emit_entering() -> void:
	_page_container.emit_entering()
## Emits the [Signal Page.exited] signal in the current [Page].
func emit_exited() -> void:
	_page_container.emit_exited()
## Emits the [Signal Page.exiting] signal in the current [Page].
func emit_exiting() -> void:
	_page_container.emit_exiting()


## Returns if the highlight can be seen.
## [br][br]
## Also see [member include_highlight] and [member highlight_height].
func is_highlight_visible() -> bool:
	return include_highlight && highlight_height > 0
## Returns if the shadow can be seen.
## [br][br]
## Also see [member shadow_gradient] and [member shadow_height].
func is_shadow_visible() -> bool:
	return shadow_gradient != null && shadow_height > 0
## Returns if the tab background can be seen.
## [br][br]
## Also see [member tab_bg_style].
func is_tab_background_visible() -> bool:
	return tab_bg_style != null
## Returns if the page background can be seen.
## [br][br]
## Also see [member bg_style].
func is_page_background_visible() -> bool:
	return bg_style != null
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
