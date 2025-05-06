# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends EditorPlugin

const GLOBAL_FOLDER := "res://addons/FreeControl/src/Other/Global/"
const CUSTOM_CLASS_FOLDER := "res://addons/FreeControl/src/CustomClasses/"
const ICON_FOLDER := "res://addons/FreeControl/assets/icons/CustomType/"

func _enter_tree() -> void:
	# AnimatableControls
		# Control
	add_custom_type(
		"AnimatableControl",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/control/AnimatableControl.gd"), 
		load(ICON_FOLDER + "AnimatableControl.svg")
	)
	add_custom_type(
		"AnimatableScrollControl",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/control/AnimatableScrollControl.gd"), 
		load(ICON_FOLDER + "AnimatableScrollControl.svg")
	)
	add_custom_type(
		"AnimatableZoneControl",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/control/AnimatableZoneControl.gd"), 
		load(ICON_FOLDER + "AnimatableZoneControl.svg")
	)
	add_custom_type(
		"AnimatableVisibleControl",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/control/AnimatableVisibleControl.gd"), 
		load(ICON_FOLDER + "AnimatableVisibleControl.svg")
	)
		# Mount
	add_custom_type(
		"AnimatableMount",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/mount/AnimatableMount.gd"), 
		load(ICON_FOLDER + "AnimatableMount.svg")
	)
	add_custom_type(
		"AnimatableTransformationMount",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "AnimatableControl/mount/AnimatableTransformationMount.gd"), 
		load(ICON_FOLDER + "AnimatableTransformationMount.svg")
	)
	
	# Carousel
	add_custom_type(
		"Carousel",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Carousel/Carousel.gd"), 
		load(ICON_FOLDER + "Carousel.svg")
	)
	
	# CircularContainer
	add_custom_type(
		"CircularContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "CircularContainer/CircularContainer.gd"), 
		load(ICON_FOLDER + "CircularContainer.svg")
	)
	
	# Drawer
	add_custom_type(
		"Drawer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Drawer/Drawer.gd"), 
		load(ICON_FOLDER + "Drawer.svg")
	)
	
	# ProportionalContainer
	add_custom_type(
		"ProportionalContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "ProportionalContainer/ProportionalContainer.gd"), 
		load(ICON_FOLDER + "ProportionalContainer.svg")
	)
	
	# SizeControllers
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "SizeController/MaxSizeContainer.gd"), 
		load(ICON_FOLDER + "MaxSizeContainer.svg")
	)
	add_custom_type(
		"MaxRatioContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "SizeController/MaxRatioContainer.gd"), 
		load(ICON_FOLDER + "MaxRatioContainer.svg")
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
	
	# Carousel
	remove_custom_type("Carousel")
	
	# CircularContainer
	remove_custom_type("CircularContainer")
	
	# Drawer
	remove_custom_type("Drawer")
	
	# ProportionalContainer
	remove_custom_type("ProportionalContainer")
	
	# SizeControllers
	remove_custom_type("MaxRatioContainer")
	remove_custom_type("MaxSizeContainer")
