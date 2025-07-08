@tool
class_name ExampleTab extends BaseRouterTab


@onready var _color: ColorRect = %Color



func _args_updated() -> void:
	pass
func _on_focus_updated(focused : bool, animate : bool) -> void:
	_color.color = Color.AQUA if focused else Color.BURLYWOOD
func _on_disable_updated(disabled : bool, animate : bool) -> void:
	pass
