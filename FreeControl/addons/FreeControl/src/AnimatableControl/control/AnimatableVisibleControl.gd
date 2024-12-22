@tool
class_name AnimatableVisibleControl extends AnimatableScrollControl
## A container to be used for free transformation, within a UI, depending on if the node is visible in a [ScrollContainer] scroll.

## Emitted when requested threshold has been entered.
signal entered_threshold
## Emitted when requested threshold has been exited.
signal exited_threshold
## Emitted when this node's [AnimatableMount]'s rect entered visible range.
signal entered_screen
## Emitted when this node's [AnimatableMount]'s rect exited visible range.
signal exited_screen

## Modes of threshold type checking.
enum CHECK_MODE {
	NONE = 0b000, ## No behavior.
	HORIZONTAL = 0b001, ## Only checks horizontally using [member threshold_horizontal].
	VERTICAL = 0b010, ## Only checks vertically using [member threshold_vertical].
	BOTH = 0b011 ## Checks horizontally and vertically.
}

## Color for inner highlighting - Indicates when visiblity is required to met threshold.
const HIGHLIGHT_COLOR := Color(Color.RED, 0.3)
## Color for overlap highlighting - Indicates when visiblity is required, starting from the far end, to met threshold.
const ANTI_HIGHLIGHT_COLOR := Color(Color.DARK_CYAN, 1)
## Color for helpful lines to make highlighting for clear.
const INTERSECT_HIGHLIGHT_COLOR := Color(Color.RED, 0.8)

@export_group("Mode")
## Sets the mode of threshold type checking.
@export var check_mode: CHECK_MODE = CHECK_MODE.NONE:
	set(val):
		if check_mode != val:
			check_mode = val
			notify_property_list_changed()
			queue_redraw()

@export_group("Threshold")
## The minimum horizontal percentage this node's [AnimatableMount]'s rect must be visible in [member scroll] for this node to be consistered visible.
@export_range(0, 1) var threshold_horizontal : float = 0.5:
	set(val):
		if threshold_horizontal != val:
			threshold_horizontal = val
			_scrolled_horizontal(0)
			queue_redraw()
## The minimum vertical percentage this node's [AnimatableMount]'s rect must be visible in [member scroll] for this node to be consistered visible.
@export_range(0, 1) var threshold_vertical : float = 0.5:
	set(val):
		if threshold_vertical != val:
			threshold_vertical = val
			_scrolled_vertical(0)
			queue_redraw()
var _last_threshold_horizontal : float
var _last_threshold_vertical : float
var _last_visible : bool

@export_group("Indicator")
## [b]Editor usage only.[/b]
## [br]
## Shows or hides the helpful threshold highlighter.
@export var hide_indicator : bool = false:
	set(val):
		if hide_indicator != val:
			hide_indicator = val
			queue_redraw()

func _scrolled_horizontal(_scroll : float) -> void:
	if !(check_mode & CHECK_MODE.HORIZONTAL): return
	
	var val : float = is_visible_percent()
	# Checks if visible
	if val > 0:
		# If visible, but wasn't visible last scroll, then it entered visible area
		if !_last_visible:
			_on_visible_enter()
			entered_screen.emit()
			_last_visible = true
		# Calls the while function
		_while_visible(val)
	# Else, if visible last frame, then it exited visible area
	elif _last_visible:
		_on_visible_exit()
		exited_screen.emit()
		_last_visible = false
	
	val = get_visible_horizontal_percent()
	# Checks if in threshold
	if val >= threshold_horizontal:
		# If in  threshold, but not last frame, then it entered threshold area
		if _last_threshold_horizontal < threshold_horizontal:
			_on_threshold_enter()
			entered_threshold.emit()
		# Calls the while function
		_while_threshold(val)
	# If in threshold, but not last frame, then it entered threshold area
	elif _last_threshold_horizontal > threshold_horizontal:
		_on_threshold_exit()
		exited_threshold.emit()
	_last_threshold_horizontal = val
func _scrolled_vertical(_scroll : float) -> void:
	if !(check_mode & CHECK_MODE.VERTICAL): return
	
	var val : float = is_visible_percent()
	# Checks if visible
	if val > 0:
		# If visible, but wasn't visible last scroll, then it entered visible area
		if !_last_visible:
			_on_visible_enter()
			entered_screen.emit()
			_last_visible = true
		# Calls the while function
		_while_visible(val)
	# Else, if visible last frame, then it exited visible area
	elif _last_visible:
		_on_visible_exit()
		exited_screen.emit()
		_last_visible = false
	
	val = get_visible_vertical_percent()
	# Checks if in threshold
	if val >= threshold_vertical:
		# If in  threshold, but not last frame, then it entered threshold area
		if _last_threshold_vertical < threshold_vertical:
			_on_threshold_enter()
			entered_threshold.emit()
		# Calls the while function
		_while_threshold(val)
	# If in threshold, but not last frame, then it entered threshold area
	elif _last_threshold_vertical > threshold_vertical:
		_on_threshold_exit()
		exited_threshold.emit()
	_last_threshold_vertical = val

func _validate_property(property: Dictionary) -> void:
	super(property)
	match property.name:
		"threshold_horizontal":
			if !(check_mode & CHECK_MODE.HORIZONTAL):
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"threshold_vertical":
			if !(check_mode & CHECK_MODE.VERTICAL):
				property.usage |= PROPERTY_USAGE_READ_ONLY

func _ready() -> void:
	if !item_rect_changed.is_connected(queue_redraw) && Engine.is_editor_hint():
		item_rect_changed.connect(queue_redraw)
	super()
func _draw() -> void:
	if !_mount || !Engine.is_editor_hint() || hide_indicator: return
	
	draw_set_transform(-position, 0, Vector2.ONE)
	draw_rect(Rect2(Vector2.ZERO, size), Color.CORAL, false)
	
	match check_mode:
		CHECK_MODE.HORIZONTAL:
			var left := threshold_horizontal * size.x
			var right := size.x - left
			
			if threshold_horizontal > 0.5:
				left = size.x - left
				right = size.x - right
			
			_draw_highlight(
				left,
				0,
				right,
				size.y,
				threshold_horizontal <= 0.5
			)
		CHECK_MODE.VERTICAL:
			var top := threshold_vertical * size.y
			var bottom := size.y - top
			
			if threshold_vertical > 0.5:
				top = size.y - top
				bottom = size.y - bottom
			
			_draw_highlight(
				0,
				top,
				size.x,
				bottom,
				threshold_vertical <= 0.5
			)
		CHECK_MODE.BOTH:
			var left := threshold_horizontal * size.x
			var right := size.x - left
			var top := threshold_vertical * size.y
			var bottom := size.y - top
			
			var draw_middle : bool = true
			if threshold_horizontal > 0.5:
				left = size.x - left
				right = size.x - right
				draw_middle = false
			if threshold_vertical > 0.5:
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
				if threshold_horizontal >= 0.5:
					if threshold_vertical < 0.5:
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
				elif threshold_vertical >= 0.5:
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

## Returns the rect [threshold_horizontal] and [threshold_vertical] create.
func get_threshold_rect(consider_mode : bool = false) -> Rect2:
	if !consider_mode || check_mode == CHECK_MODE.BOTH:
		return Rect2(Vector2(threshold_horizontal, threshold_vertical) * size, Vector2(1.0 - threshold_horizontal, 1.0 - threshold_vertical) * size)
	
	return Rect2(Vector2(threshold_horizontal, threshold_vertical) * size, Vector2(1.0 - threshold_horizontal, 1.0 - threshold_vertical) * size)

## A virtual function that is called when this node entered the visible area of it's scroll
func _on_visible_enter() -> void: pass
## A virtual function that is called when this node left the visible area of it's scroll
func _on_visible_exit() -> void: pass
## A virtual function that is called while this node is in the visible  area of it's scroll. Is called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current visible percent.
func _while_visible(intersect : float) -> void: pass
## A virtual function that is called when this node's visible threshold has been met.
func _on_threshold_enter() -> void: pass
## A virtual function that is called when this node's visible threshold is no longer met.
func _on_threshold_exit() -> void: pass
## A virtual function that is called while this node's visible threshold is met. Is called after each scroll of [member scroll].
## [br][br]
## Paramter [param intersect] is the current threshold value met.
func _while_threshold(intersect : float) -> void: pass
