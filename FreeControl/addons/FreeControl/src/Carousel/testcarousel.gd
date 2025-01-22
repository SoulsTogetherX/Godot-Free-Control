@tool
extends Carousel

func _ready() -> void:
	super()
	snap_end.connect(_on_snap_end)
	snap_begin.connect(_on_snap_begin)
	drag_end.connect(_on_drag_end)
	drag_begin.connect(_on_drag_begin)

func _on_snap_end() -> void:
	print("snap_end")
func _on_snap_begin() -> void:
	print("snap_begin")
func _on_drag_end() -> void:
	print("drag_end")
func _on_drag_begin() -> void:
	print("drag_begin")
