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
	
	# Buttons
		# Base
	add_custom_type(
		"AnimatedSwitch",
		"BaseButton",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/AnimatedSwitch.gd"), 
		null
	)
	add_custom_type(
		"HoldButton",
		"BaseButton",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/HoldButton.gd"), 
		null
	)
	
		# Complex
	add_custom_type(
		"AnimatedSwitch",
		"BaseButton",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/AnimatedSwitch.gd"), 
		null
	)
	add_custom_type(
		"ModulateTransitionButton",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Complex/ModulateTransitionButton.gd"), 
		null
	)
	add_custom_type(
		"StyleTransitionButton",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Complex/StyleTransitionButton.gd"), 
		null
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
	
	# PaddingContainer
	add_custom_type(
		"PaddingContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "PaddingContainer/PaddingContainer.gd"), 
		load(ICON_FOLDER + "PaddingContainer.svg")
	)
	
	# ProportionalContainer
	add_custom_type(
		"ProportionalContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "ProportionalContainer/ProportionalContainer.gd"), 
		load(ICON_FOLDER + "ProportionalContainer.svg")
	)
	
	# Routers
		# Base
			# Page
	add_custom_type(
		"Page",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Routers/Base/Page.gd"), 
		null
	)
			# PageInfo
	add_custom_type(
		"PageInfo",
		"Resource",
		load(CUSTOM_CLASS_FOLDER + "Routers/Base/PageInfo.gd"), 
		null
	)
	
		# RouterStack
	add_custom_type(
		"RouterStack",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterStack.gd"), 
		null
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
	
	# SwapContainer
	add_custom_type(
		"SwapContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "SwapContainer/SwapContainer.gd"), 
		null
	)
	
	# TransitionContainers
	add_custom_type(
		"ModulateTransitionContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/ModulateTransitionContainer.gd"), 
		null
	)
	add_custom_type(
		"StyleTransitionContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/StyleTransitionContainer.gd"), 
		null
	)
	add_custom_type(
		"StyleTransitionPanel",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/StyleTransitionPanel.gd"), 
		null
	)

func _exit_tree() -> void:
	# AnimatableControls
		# Control
	remove_custom_type("AnimatableControl")
	remove_custom_type("AnimatableScrollControl")
	remove_custom_type("AnimatableZoneControl")
	remove_custom_type("AnimatableVisibleControl")
		# Mount
	remove_custom_type("AnimatableMount")
	remove_custom_type("AnimatableTransformationMount")
	
	# Buttons
		# Base
	remove_custom_type("AnimatedSwitch")
	remove_custom_type("HoldButton")
	
		# Complex
	remove_custom_type("AnimatedSwitch")
	remove_custom_type("ModulateTransitionButton")
	remove_custom_type("StyleTransitionButton")
	
	# Carousel
	remove_custom_type("Carousel")
	
	# CircularContainer
	remove_custom_type("CircularContainer")
	
	# Drawer
	remove_custom_type("Drawer")
	
	# PaddingContainer
	remove_custom_type("PaddingContainer")
	
	# ProportionalContainer
	remove_custom_type("ProportionalContainer")
	
	# Routers
		# Base
			# Page
	remove_custom_type("Page")
			# PageInfo
	remove_custom_type("PageInfo")
	
		# RouterStack
	remove_custom_type("RouterStack")
	
	# SizeControllers
	remove_custom_type("MaxSizeContainer")
	remove_custom_type("MaxRatioContainer")
	
	# SwapContainer
	remove_custom_type("SwapContainer")
	
	# TransitionContainers
	remove_custom_type("ModulateTransitionContainer")
	remove_custom_type("StyleTransitionContainer")
	remove_custom_type("StyleTransitionPanel")
