# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
class_name AnimatableVisibleControl extends AnimatableScrollControl
## A container to be used for free transformation, within a UI, depending on if
## the node is visible in a [ScrollContainer] scroll.

#region Signals
## Emitted when requested threshold has been entered.
signal entered_threshold
## Emitted when requested threshold has been exited.
signal exited_threshold
## Emitted when this node's [AnimatableMount]'s rect entered visible range.
signal entered_screen
## Emitted when this node's [AnimatableMount]'s rect exited visible range.
signal exited_screen
#endregion


#region Enums
## Modes of threshold type checking.
enum CHECK_MODE {
	NONE = 0b000, ## No behavior.
	HORIZONTAL = 0b001, ## Only checks horizontally using [member threshold_horizontal].
	VERTICAL = 0b010, ## Only checks vertically using [member threshold_vertical].
	BOTH = 0b011 ## Checks horizontally and vertically.
}

## Modes of threshold size.
enum THRESHOLD_EDITOR_DIMS {
	None = 0b00, ## Both horizontal and vertical axis are based on ratio.
	Horizontal = 0b01, ## Horizontal axis is based on exact pixel and vertical on ratio.
	Vertical = 0b10, ## Horizontal axis is based on ratio and vertical on exact pixel.
	Both = 0b11, ## Both horizontal and vertical axis are based on exact pixel.
}
#endregion


#region Constants
## Color for inner highlighting - Indicates when visiblity is required to met
## threshold.
const HIGHLIGHT_COLOR := Color(Color.RED, 0.3)
## Color for overlap highlighting - Indicates when visiblity is required, starting
## from the far end, to met threshold.
const ANTI_HIGHLIGHT_COLOR := Color(Color.DARK_CYAN, 1)
## Color for helpful lines to make highlighting for clear.
const INTERSECT_HIGHLIGHT_COLOR := Color(Color.RED, 0.8)
#endregion


#region External Variables
@export_group("Mode")
## Sets the mode of threshold type checking.
@export var check_mode: CHECK_MODE = CHECK_MODE.NONE:
	set(val):
		if check_mode != val:
			check_mode = val
			notify_property_list_changed()
			queue_redraw()

## A flag variable used to distinguish if the threshold amount is described by
## a ratio of the size of the [member AnimatableScrollControl.scroll] value, or
## by a const pixel value.[br]
## Horizontal and vertical axis are consistered differently.
## [br][br]
## See [enum THRESHOLD_EDITOR_DIMS], [member threshold_horizontal], and [member threshold_vertical].
var threshold_pixel : int:
	set(val):
		if (threshold_pixel ^ val) & THRESHOLD_EDITOR_DIMS.Horizontal:
			_scrolled_horizontal(get_scroll_offset().x)
		if (threshold_pixel ^ val) & THRESHOLD_EDITOR_DIMS.Vertical:
			_scrolled_vertical(get_scroll_offset().y)
		threshold_pixel = val
		notify_property_list_changed()
		queue_redraw()
## The minimum horizontal percentage this node's [AnimatableMount]'s rect must be
## visible in [member scroll] for this node to be consistered visible.
var threshold_horizontal : float = 0.5:
	set(val):
		if threshold_horizontal != val:
			threshold_horizontal = val
			_scrolled_horizontal(0)
			queue_redraw()
## The minimum vertical percentage this node's [AnimatableMount]'s rect must be
## visible in [member scroll] for this node to be consistered visible.
var threshold_vertical : float = 0.5:
	set(val):
		if threshold_vertical != val:
			threshold_vertical = val
			_scrolled_vertical(0)
			queue_redraw()
## [b]Editor usage only.[/b] Shows or hides the helpful threshold highlighter.
var hide_indicator : bool = true:
	set(val):
		if hide_indicator != val:
			hide_indicator = val
			queue_redraw()
#endregion


#region Private Variables
var _last_threshold_horizontal : float
var _last_threshold_vertical : float
var _last_visible : bool
#endregion


#region Private Virtual Methods
func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary] = []
	var horizontal : int = 0 if check_mode & CHECK_MODE.HORIZONTAL else PROPERTY_USAGE_READ_ONLY
	var vertical : int = 0 if check_mode & CHECK_MODE.VERTICAL else PROPERTY_USAGE_READ_ONLY
	var either : int = horizontal & vertical
	
	var options : String
	if !horizontal: options = "Horizontal:1,"
	if !vertical: options += "Vertical:2"
	
	ret.append({
		"name": "Threshold",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_string": ""
	})
	ret.append({
		"name": "threshold_pixel",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": options,
		"usage": PROPERTY_USAGE_DEFAULT | either
	})
	ret.append({
		"name": "threshold_horizontal",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | horizontal,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 100, 0.001, suffix:px"
	}.merged({} if threshold_pixel & 1 else {
		"hint_string": "0, 1, 0.001"
	}, true))
	ret.append({
		"name": "threshold_vertical",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT | vertical,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 100, 0.001, suffix:px"
	}.merged({} if threshold_pixel & 2 else {
		"hint_string": "0, 1, 0.001"
	}, true))
	
	ret.append({
		"name": "Indicator",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
		"hint_str": ""
	})
	ret.append({
		"name": "hide_indicator",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	return ret
func _property_can_revert(property: StringName) -> bool:
	if property == "threshold_pixel":
		if self[property] != 0: return true
	elif property in ["threshold_horizontal", "threshold_vertical"]:
		if self[property] != 0.5: return true
	elif property == "hide_indicator":
		return !hide_indicator
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property == "threshold_pixel":
		return 0
	elif property in ["threshold_horizontal", "threshold_vertical"]:
		return 0.5
	elif property == "hide_indicator":
		return true
	return null

func _get_threshold_size() -> Array[Vector2]:
	var mount := get_mount()
	if !mount:
		return [Vector2.ZERO, Vector2.ZERO]
		
	var ratio_thr : Vector2
	var full_thr : Vector2
	
	if is_zero_approx(mount.size.x):
		ratio_thr.x = 1
		full_thr.x = mount.size.x
	elif threshold_pixel & THRESHOLD_EDITOR_DIMS.Horizontal:
		var hor := clamp(threshold_horizontal, 0, mount.size.x)
		ratio_thr.x = hor / mount.size.x
		full_thr.x = hor
	else:
		var hor := clamp(threshold_horizontal, 0, 1)
		ratio_thr.x = hor
		full_thr.x = hor * mount.size.x
	
	if is_zero_approx(mount.size.y):
		ratio_thr.y = 1
		full_thr.y = mount.size.y
	elif threshold_pixel & THRESHOLD_EDITOR_DIMS.Vertical:
		var vec := clamp(threshold_vertical, 0, mount.size.y)
		ratio_thr.y = vec / mount.size.y
		full_thr.y = vec
	else:
		var vec := clamp(threshold_vertical, 0, 1)
		ratio_thr.y = vec
		full_thr.y = vec * mount.size.y
	
	return [ratio_thr, full_thr]

func _draw() -> void:
	if !Engine.is_editor_hint() || hide_indicator:
		return
	
	var mount := get_mount()
	if !mount:
		return
	
	var threshold_adjust := _get_threshold_size()
	
	draw_set_transform(-position)
	draw_rect(Rect2(Vector2.ZERO, size), Color.CORAL, false)
	
	match check_mode:
		CHECK_MODE.HORIZONTAL:
			var left := threshold_adjust[1].x
			var right := size.x - left
			
			if threshold_adjust[0].x > 0.5:
				left = size.x - left
				right = size.x - right
			
			_draw_highlight(
				left,
				0,
				right,
				size.y,
				threshold_adjust[0].x < 0.5
			)
		CHECK_MODE.VERTICAL:
			var top := threshold_adjust[1].y
			var bottom := size.y - top
			
			if threshold_adjust[0].y > 0.5:
				top = size.y - top
				bottom = size.y - bottom
			
			_draw_highlight(
				0,
				top,
				size.x,
				bottom,
				threshold_adjust[0].y < 0.5
			)
		CHECK_MODE.BOTH:
			var left := threshold_adjust[1].x
			var right := size.x - left
			var top := threshold_adjust[1].y
			var bottom := size.y - top
			
			var draw_middle : bool = true
			if threshold_adjust[0].x >= 0.5:
				left = size.x - left
				right = size.x - right
				draw_middle = false
			if threshold_adjust[0].y >= 0.5:
				top = size.y - top
				bottom = size.y - bottom
				draw_middle = false
			
			_draw_highlight(
				left,
				top,
				right,
				bottom,
				draw_middle
			)
			
			if !draw_middle:
				if threshold_adjust[0].x >= 0.5:
					if threshold_adjust[0].y < 0.5:
						draw_line(
							Vector2(left, top),
							Vector2(right, top),
							INTERSECT_HIGHLIGHT_COLOR,
							5
						)
						draw_line(
							Vector2(left, bottom),
							Vector2(right, bottom),
							INTERSECT_HIGHLIGHT_COLOR,
							5
						)	
				elif threshold_adjust[0].y >= 0.5:
					draw_line(
						Vector2(left, top),
						Vector2(left, bottom),
						INTERSECT_HIGHLIGHT_COLOR,
						5
					)
					draw_line(
						Vector2(right, top),
						Vector2(right, bottom),
						INTERSECT_HIGHLIGHT_COLOR,
						5
					)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			queue_redraw()
	super(what)
#endregion


#region Custom Methods Overwriting
func _scrolled_horizontal(_scroll_hor : float) -> void:
	if !(check_mode & CHECK_MODE.HORIZONTAL): return
	
	var threshold_adjust := _get_threshold_size()
	var val : float = is_visible_percent()
	
	# Checks if visible
	if val > 0:
		# If visible, but wasn't visible last scroll, then it entered visible area
		if !_last_visible:
			entered_screen.emit()
			_last_visible = true
		# Calls the while function
		_while_visible(val)
	# Else, if visible last frame, then it exited visible area
	elif _last_visible:
		_while_visible(0)
		exited_screen.emit()
		_last_visible = false
	
	val = get_visible_horizontal_percent()
	# Checks if in threshold
	if val >= threshold_adjust[0].x:
		# If in  threshold, but not last frame, then it entered threshold area
		if _last_threshold_horizontal < threshold_adjust[0].x:
			entered_threshold.emit()
		# Calls the while function
		_while_threshold(val)
	# If in threshold, but not last frame, then it entered threshold area
	elif _last_threshold_horizontal > threshold_adjust[0].x:
		_while_threshold(0)
		exited_threshold.emit()
	_last_threshold_horizontal = val
func _scrolled_vertical(_scroll_ver : float) -> void:
	if !(check_mode & CHECK_MODE.VERTICAL): return
	
	var threshold_adjust := _get_threshold_size()
	var val : float = is_visible_percent()
	
	# Checks if visible
	if val > 0:
		# If visible, but wasn't visible last scroll, then it entered visible area
		if !_last_visible:
			entered_screen.emit()
			_last_visible = true
		# Calls the while function
		_while_visible(val)
	# Else, if visible last frame, then it exited visible area
	elif _last_visible:
		_while_visible(0)
		exited_screen.emit()
		_last_visible = false
	
	val = get_visible_vertical_percent()
	# Checks if in threshold
	if val >= threshold_adjust[0].y:
		# If in  threshold, but not last frame, then it entered threshold area
		if _last_threshold_vertical < threshold_adjust[0].y:
			entered_threshold.emit()
		# Calls the while function
		_while_threshold(val)
	# If in threshold, but not last frame, then it entered threshold area
	elif _last_threshold_vertical > threshold_adjust[0].y:
		_while_threshold(0)
		exited_threshold.emit()
	_last_threshold_vertical = val
#endregion


#region Custom Virtual Methods
## A virtual function that is called while this node is in the visible area of it's
## scroll. Is called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current visible percent.
func _while_visible(intersect : float) -> void: pass
## A virtual function that is called while this node's visible threshold is met. Is
## called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current threshold value met.
func _while_threshold(intersect : float) -> void: pass
#endregion


#region Private Methods
## Returns the rect [threshold_horizontal] and [threshold_vertical] create.
func get_threshold_rect(consider_mode : bool = false) -> Rect2:
	var threshold_adjust := _get_threshold_size()
	return Rect2(threshold_adjust[1], size - threshold_adjust[1])
#endregion


#region Public Methods
## Returns the rect [threshold_horizontal] and [threshold_vertical] create.
func _draw_highlight(
		left : float,
		top : float,
		right : float,
		bottom : float,
		draw_middle : bool
	) -> void:
	# Middle
	if draw_middle:
		draw_rect(Rect2(Vector2(left, top), Vector2(right - left, bottom - top)), HIGHLIGHT_COLOR)
		return
	# Outer
		# Left
	draw_rect(Rect2(Vector2(0, 0), Vector2(left, size.y)), ANTI_HIGHLIGHT_COLOR)
		# Right
	draw_rect(Rect2(Vector2(right, 0), Vector2(size.x - right, size.y)), ANTI_HIGHLIGHT_COLOR)
		# Top
	draw_rect(Rect2(Vector2(left, 0), Vector2(right - left, top)), ANTI_HIGHLIGHT_COLOR)
		# Bottom
	draw_rect(Rect2(Vector2(left, bottom), Vector2(right - left, size.y - bottom)), ANTI_HIGHLIGHT_COLOR)
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
