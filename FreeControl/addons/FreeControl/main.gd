@tool
extends EditorPlugin

const SCRIPT_FOLDER := "res://addons/FreeControl/src/"
const ICON_FOLDER := "res://addons/FreeControl/assets/icons/"

func _enter_tree() -> void:
	# AnimatableControl
		# Control
	add_custom_type(
		"AnimatableControl",
		"Container",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableControl.gd"), 
		load(ICON_FOLDER + "AnimatableControl.svg")
	)
	add_custom_type(
		"AnimatableScrollControl",
		"AnimatableControl",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableScrollControl.gd"), 
		load(ICON_FOLDER + "AnimatableScrollControl.svg")
	)
	add_custom_type(
		"AnimatableVisibleControl",
		"AnimatableScrollControl",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableVisibleControl.gd"), 
		load(ICON_FOLDER + "AnimatableVisibleControl.svg")
	)
		# Mount
	add_custom_type(
		"AnimatableMount",
		"Control",
		load(SCRIPT_FOLDER + "AnimatableControl/mount/AnimatableMount.gd"), 
		load(ICON_FOLDER + "AnimatableMount.svg")
	)
	add_custom_type(
		"AnimatableTransformationMount",
		"AnimatableMount",
		load(SCRIPT_FOLDER + "AnimatableControl/mount/AnimatableTransformationMount.gd"), 
		load(ICON_FOLDER + "AnimatableTransformationMount.svg")
	)
	
	# CircularContainer
	add_custom_type(
		"CircularContainer",
		"Container",
		load(SCRIPT_FOLDER + "CircularContainer/CircularContainer.gd"), 
		load(ICON_FOLDER + "CircularContainer.svg")
	)
	
	# ProportionalContainer
	add_custom_type(
		"ProportionalContainer",
		"Container",
		load(SCRIPT_FOLDER + "ProportionalContainer/ProportionalContainer.gd"), 
		load(ICON_FOLDER + "ProportionalContainer.svg")
	)
	
	# SizeController
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load(SCRIPT_FOLDER + "SizeController/MaxSizeContainer.gd"), 
		load(ICON_FOLDER + "MaxSizeContainer.svg")
	)
	add_custom_type(
		"MaxRatioContainer",
		"MaxSizeContainer",
		load(SCRIPT_FOLDER + "SizeController/MaxRatioContainer.gd"), 
		load(ICON_FOLDER + "MaxRatioContainer.svg")
	)

func _exit_tree() -> void:
	# AnimatableControl
		# Control
	remove_custom_type("AnimatableControl")
	remove_custom_type("AnimatableScrollControl")
	remove_custom_type("AnimatableVisibleControl")
		# Mount
	remove_custom_type("AnimatableMount")
	remove_custom_type("AnimatableTransformationMount")
	
	# CircularContainer
	remove_custom_type("CircularContainer")
	
	# ProportionalContainer
	remove_custom_type("ProportionalContainer")
	
	# SizeController
	remove_custom_type("MaxRatioContainer")
	remove_custom_type("MaxSizeContainer")
