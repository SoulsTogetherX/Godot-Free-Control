# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends EditorPlugin

const SCRIPT_FOLDER := "res://addons/FreeControl/src/"
const ICON_FOLDER := "res://addons/FreeControl/assets/icons/CustomType/"

func _enter_tree() -> void:
	# AnimatableControls
		# Control
	add_custom_type(
		"AnimatableControl",
		"Container",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableControl.gd"), 
		load(ICON_FOLDER + "AnimatableControl.svg")
	)
	add_custom_type(
		"AnimatableScrollControl",
		"Container",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableScrollControl.gd"), 
		load(ICON_FOLDER + "AnimatableScrollControl.svg")
	)
	add_custom_type(
		"AnimatableZoneControl",
		"Container",
		load(SCRIPT_FOLDER + "AnimatableControl/control/AnimatableZoneControl.gd"), 
		load(ICON_FOLDER + "AnimatableZoneControl.svg")
	)
	add_custom_type(
		"AnimatableVisibleControl",
		"Container",
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
		"Control",
		load(SCRIPT_FOLDER + "AnimatableControl/mount/AnimatableTransformationMount.gd"), 
		load(ICON_FOLDER + "AnimatableTransformationMount.svg")
	)
	
	#Carousel
	add_custom_type(
		"Carousel",
		"Container",
		load(SCRIPT_FOLDER + "Carousel/Carousel.gd"), 
		load(ICON_FOLDER + "Carousel.svg")
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
	
	# SizeControllers
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load(SCRIPT_FOLDER + "SizeController/MaxSizeContainer.gd"), 
		load(ICON_FOLDER + "MaxSizeContainer.svg")
	)
	add_custom_type(
		"MaxRatioContainer",
		"Container",
		load(SCRIPT_FOLDER + "SizeController/MaxRatioContainer.gd"), 
		load(ICON_FOLDER + "MaxRatioContainer.svg")
	)
	
	# Typography
	add_custom_type(
		"Typography",
		"Label",
		load(SCRIPT_FOLDER + "Typography/Typography.gd"), 
		load(ICON_FOLDER + "Typography.svg")
	)

func _exit_tree() -> void:
	# AnimatableControls
		# Control
	remove_custom_type("AnimatableControl")
	remove_custom_type("AnimatableScrollControl")
	remove_custom_type("AnimatablePercentControl")
	remove_custom_type("AnimatableVisibleControl")
		# Mount
	remove_custom_type("AnimatableMount")
	remove_custom_type("AnimatableTransformationMount")
	
	#Carousel
	remove_custom_type("Carousel")
	
	# CircularContainer
	remove_custom_type("CircularContainer")
	
	# ProportionalContainer
	remove_custom_type("ProportionalContainer")
	
	# SizeControllers
	remove_custom_type("MaxRatioContainer")
	remove_custom_type("MaxSizeContainer")
	
	# Typography
	remove_custom_type("Typography")
