# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name RouterSlide extends Container
## A [Container] router used to display multiple pages via tab pressed.


#region Constants (PackedScene Paths)
## The UID to the page slide script.
const PAGE_SLIDE_CONTAINER_UID = "uid://dt0ohckuas7ur"
## The UID to the content container script.
const CONTENT_CONTAINER_UID = "uid://3ofgv2q2gqjt"
## The UID to the highlight container script.
const HIGHLIGHT_CONTAINER_UID = "uid://cssmagqrr3ly1"
## The UID to the tabs container script.
const TABS_CONTAINER_UID = "uid://b5mte6dbnkbc5"
#endregion


#region External Variables
@export_group("Shared Info")
## All shared info about this router
@export var router_info : RouterSlideInfo:
	set(val):
		if val != router_info:
			if !val:
				val = RouterSlideInfo.new()
			router_info = val
			
			if !is_node_ready():
				return
			_on_info_update()

@export_group("Scene Layout")
## If [code]true[/code], tabs will be placed at the top of the node.
## Otherwise, they will be placed at the bottom.
@export var tabs_top : bool = false:
	set(val):
		if val != tabs_top:
			tabs_top = val
			queue_sort()
## The height of the tabs in pixels.
@export var tab_height : float = 70:
	set(val):
		if val != tab_height:
			tab_height = val
			queue_sort()
## The local z_index the tabs bar will have, from this node.
## Value can only be positive.
@export_range(0, 4096) var tab_z_index : int:
	set(val):
		if val != tab_z_index:
			tab_z_index = val
			if !is_node_ready():
				return
			
			_tabs_container.z_index = val


@export_group("Tab Layout")
@export_subgroup("Tab Shadow")
## The height of the shadow emits from the tabs.
@export var shadow_height : float = 0:
	set(val):
		if val != shadow_height:
			shadow_height = val
			queue_sort()
## The gradient of the shadow emited from the tabs.
@export var shadow_gradient : Gradient:
	set(val):
		if val != shadow_gradient:
			shadow_gradient = val
			if !is_node_ready():
				return
			
			if shadow_gradient:
				var texture := StyleBoxTexture.new()
				texture.texture = GradientTexture1D.new()
				texture.texture.gradient = shadow_gradient
				_change_theme(_tabs_shadow, texture)
			else:
				_change_theme(_tabs_shadow, null)
## If [code]true[/code], the shadow will be rendered under the highlight
@export var shadow_under_highlight : bool = true:
	set(val):
		if val != shadow_under_highlight:
			shadow_under_highlight = val
			_reorder_shadow_rendering()


@export_group("Highlight Layout")
## If [code]true[/code], display a highlight near the tabs. Otherwise don't.
@export var include_highlight : bool = true:
	set(val):
		if val != include_highlight:
			include_highlight = val
			queue_sort()
## If [code]true[/code], the highlight will be displayed above the tabs. Otherwise,
## it will be displayed below the tab's bottom.
@export var top_highlight : bool = true:
	set(val):
		if val != top_highlight:
			top_highlight = val
			queue_sort()
## If [code]true[/code], the tab background will extend to cover the highlight.
## Otherwise, the highlight will extend past the tab background.
@export var inset_highlight : bool = false:
	set(val):
		if val != inset_highlight:
			inset_highlight = val
			queue_sort()
## Height of the highlight
@export var highlight_height : float = 3:
	set(val):
		if val != highlight_height:
			highlight_height = val
			queue_sort()
## Color of the highlight
@export var highlight_color : Color = Color(0.608, 0.329, 0.808):
	set(val):
		highlight_color = val
		if !is_node_ready():
			return
		
		_highlight_container.highlight_color = val


@export_group("Background")
## If [code]true[/code], [member bg_style] will be displayed under the
## [member tab_bg_style] too.
@export var bg_include_tabs : bool = false:
	set(val):
		if val != bg_include_tabs:
			bg_include_tabs = val
			queue_sort()
## Background style for the [Page] nodes.
@export var content_bg_style : StyleBox:
	set(val):
		if val != content_bg_style:
			content_bg_style = val
			if !is_node_ready():
				return
			
			_change_theme(_tabs_background, content_bg_style)
## Background style for the tab nodes.
## [br][br]
## Also see [member tab_scene].
@export var tab_bg_style : StyleBox:
	set(val):
		if val != tab_bg_style:
			tab_bg_style = val
			if !is_node_ready():
				return
			
			_change_theme(_tabs_background, tab_bg_style)


@export_group("Animations")
@export_subgroup("Page")
## Length of time for this [Node] to swap [Page]s.
@export_range(0.001, 5, 0.001, "or_greater", "suffix:sec") var page_speed : float = 0.4:
	set(val):
		page_speed = val
		if !is_node_ready():
			return
		
		_content_container.animation_speed = val
## The [enum Tween.EaseType] for [Page] animation.
@export var page_ease : Tween.EaseType = Tween.EASE_IN_OUT:
	set(val):
		page_ease = val
		if !is_node_ready():
			return
		
		_content_container.animation_ease = val
## The [enum Tween.TransitionType] for [Page] animation.
@export var page_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		page_trans = val
		if !is_node_ready():
			return
		
		_content_container.animation_trans = val

@export_subgroup("Highlight")
## Length of time for the highlight to animate.
@export_range(0.001, 5, 0.001, "or_greater", "suffix:sec") var highlight_speed : float = 0.4:
	set(val):
		highlight_speed = val
		if !is_node_ready():
			return
		
		_highlight_container.animation_speed = val
## The [enum Tween.EaseType] for highlight animation.
@export var highlight_ease : Tween.EaseType = Tween.EASE_OUT:
	set(val):
		highlight_ease = val
		if !is_node_ready():
			return
		
		_highlight_container.animation_ease = val
## The [enum Tween.TransitionType] for highlight animation.
@export var highlight_trans : Tween.TransitionType = Tween.TRANS_CUBIC:
	set(val):
		highlight_trans = val
		if !is_node_ready():
			return
		
		_highlight_container.animation_trans = val
#endregion


#region Private Variables
var _content_container : Container
var _highlight_container : Container
var _tabs_container : Container

var _content_background : Panel
var _tabs_background : Panel
var _tabs_shadow : Panel
#endregion



#region Virtual Methods
func _init() -> void:
	router_info = RouterSlideInfo.new()
	
	_content_container = preload(CONTENT_CONTAINER_UID).new()
	_highlight_container = preload(HIGHLIGHT_CONTAINER_UID).new()
	_tabs_container = preload(TABS_CONTAINER_UID).new()
	
	_content_background = Panel.new()
	_tabs_background = Panel.new()
	_tabs_shadow = Panel.new()
	
	add_child(_content_background)
	add_child(_content_container)
	add_child(_tabs_background)
	
	# Option to make shadow above or below highlight
	_tabs_background.add_child(_tabs_shadow)
	_tabs_background.add_child(_highlight_container)
	
	_tabs_background.add_child(_tabs_container)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			_on_info_update()
		NOTIFICATION_SORT_CHILDREN:
			_position_componets()
#endregion


#region Private Methods (Settup)
func _on_componet_update() -> void:
	_content_container.animation_speed = page_speed
	_content_container.animation_ease = page_ease
	_content_container.animation_trans = page_trans
	
	_change_theme(_content_background, content_bg_style)
	
	_highlight_container.highlight_color = highlight_color
	_highlight_container.animation_speed = highlight_speed
	_highlight_container.animation_ease = highlight_ease
	_highlight_container.animation_trans = highlight_trans
	
	_tabs_container.z_index = tab_z_index
	
	_change_theme(_tabs_background, tab_bg_style)
	
	if shadow_gradient:
		var texture := StyleBoxTexture.new()
		texture.texture = GradientTexture1D.new()
		texture.texture.gradient = shadow_gradient
		_change_theme(_tabs_shadow, texture)
	else:
		_change_theme(_tabs_shadow, null)
func _on_info_update() -> void:
	_content_container.router_info = router_info
	_highlight_container.router_info = router_info
	_tabs_container.router_info = router_info
#endregion


#region Private Methods (Rendering)
func _reorder_shadow_rendering() -> void:
	if shadow_under_highlight:
		_tabs_background.move_child(_tabs_shadow, 0)
		return
	_tabs_background.move_child(_highlight_container, 0)
func _position_componets() -> void:
	# Sizes
	_tabs_container.size = Vector2(size.x, tab_height).max(_tabs_container.get_combined_minimum_size())
	_highlight_container.size = Vector2(size.x, highlight_height if include_highlight else 0)
	_tabs_background.size = Vector2(size.x, _tabs_container.size.y + (_highlight_container.size.y if inset_highlight else 0))
	_content_container.size = Vector2(size.x, size.y - _tabs_background.size.y)
	
	_content_background.size = Vector2(size.x, size.y - (0 if bg_include_tabs else _tabs_container.size.y))
	_tabs_shadow.size = Vector2(size.x, shadow_height)
	
	# Tab Compoents Positions
	if top_highlight:
		if inset_highlight:
			_highlight_container.position = Vector2.ZERO
			_tabs_container.position = Vector2(0, _highlight_container.size.y)
		else:
			_highlight_container.position = Vector2(0, -_highlight_container.size.y)
			_tabs_container.position = Vector2.ZERO
	else:
		_highlight_container.position = Vector2(0, _tabs_container.size.y)
		_tabs_container.position = Vector2.ZERO
	
	# Compoents Positions
	if tabs_top:
		_tabs_background.position = Vector2.ZERO
		
		_content_container.position = Vector2(0, _tabs_background.size.y)
		_content_background.position = Vector2.ZERO if bg_include_tabs else _content_container.position
		_tabs_shadow.position = Vector2(0.0, _tabs_background.size.y)
	else:
		_tabs_background.position = Vector2(0, _content_container.size.y)
		_tabs_shadow.position = Vector2(0.0, -_tabs_shadow.size.y)
		
		_content_container.position = Vector2.ZERO
		_content_background.position = _content_container.position
#endregion


#region Private Methods (Helper)
func _change_theme(panel : Panel, texture : StyleBox = null) -> void:
	if texture:
		panel.add_theme_stylebox_override("panel", texture)
		return
	panel.remove_theme_stylebox_override("panel")
#endregion


#region Public Methods (Emitters)
## Emits the [signal Page.entered] signal in the current [Page].
func emit_entered() -> void:
	if !router_info:
		return
	
	var page : Page = get_page_node(router_info.get_index())
	if !page:
		return
	
	page.entered.emit()
## Emits the [signal Page.entering] signal in the current [Page].
func emit_entering() -> void:
	if !router_info:
		return
	var page : Page = get_page_node(router_info.get_index())
	if !page:
		return
	
	page.entering.emit()
## Emits the [signal Page.exited] signal in the current [Page].
func emit_exited() -> void:
	if !router_info:
		return
	var page : Page = get_page_node(router_info.get_index())
	if !page:
		return
	
	page.exited.emit()
## Emits the [signal Page.exiting] signal in the current [Page].
func emit_exiting() -> void:
	if !router_info:
		return
	var page : Page = get_page_node(router_info.get_index())
	if !page:
		return
	
	page.exiting.emit()
#endregion


#region Public Methods (User Interaction)
## Sets the current [Page] to the given vaild index.
## [br][br]
## The [param idx] is clamped to a vaild index. If [code]animate[/code] is true
## the node will animated the transition between pages. 
func goto_page(idx : int, use_animation : bool = true, use_tab_animation : bool = true):
	if !router_info:
		return
	router_info.set_index(idx, true)
#endregion


#region Public Methods (Tab Accessors)
## Toggle if a tab is disabled or not. If so, then the user will not be able to select
## it.
## [br][br]
## Invaild [param idx] indexes are ignored. If [code]animate[/code] is true
## the node will animated the transition between pages. 
## [br][br]
## [b]NOTE[/b]: [method goto_page] will still work for the disabled tab.
func set_disable(idx : int, disable : bool, use_animation : bool = true) -> void:
	if !router_info || !router_info.is_vaild_idx(idx):
		return
	router_info.page_infos[idx].set_disabled(disable, use_animation)
#endregion


#region Public Methods (Page Accessors)
## Return the index of the currently selected page.
func get_current_index() -> int:
	if !router_info:
		return -1
	return router_info.get_index()

## Returns the indexes of all currently visible pages.
## [br][br]
## [b]NOTE[/b]: Multiple pages can be visible during animations.
func get_visible_pages() -> Array[int]:
	return _content_container.get_visible_pages()

## Returns the [Page] node associated with given [param idx].
## [br][br]
## [b]Warning[/b]: This is a required internal node, removing and freeing it
## may cause a crash.
func get_page_node(idx : int) -> Page:
	return _content_container.get_page_node(idx)
#endregion


#region Public Methods (Somponent sizes)
## Return the size of the page container.
func get_page_size() -> Vector2:
	return _content_container.size
## Return the size of the tab container.
func get_tabs_size() -> Vector2:
	return _tabs_container.size
#endregion


#region Public Methods (Visible Check)
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
	return content_bg_style != null
#endregion
# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
