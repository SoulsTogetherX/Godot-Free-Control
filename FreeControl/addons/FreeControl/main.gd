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

	# AutoSizeLabels
		# AutoSizeLabel
	add_custom_type(
		"AutoSizeLabel",
		"Label",
		load(CUSTOM_CLASS_FOLDER + "AutoSizeLabels/AutoSizeLabel.gd"), 
		load(ICON_FOLDER + "AutoSizeLabel.svg")
	)
	
	# Buttons
		# Base
	add_custom_type(
		"AnimatedSwitch",
		"BaseButton",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/AnimatedSwitch.gd"), 
		load(ICON_FOLDER + "AnimatedSwitch.svg")
	)
	add_custom_type(
		"HoldButton",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/HoldButton.gd"), 
		load(ICON_FOLDER + "HoldButton.svg")
	)
			# MotionCheck
	add_custom_type(
		"BoundsCheck",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/MotionCheck/BoundsCheck.gd"), 
		load(ICON_FOLDER + "BoundsCheck.svg")
	)
	add_custom_type(
		"DistanceCheck",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/MotionCheck/DistanceCheck.gd"), 
		load(ICON_FOLDER + "DistanceCheck.svg")
	)
	add_custom_type(
		"MotionCheck",
		"Control",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Base/MotionCheck/MotionCheck.gd"), 
		load(ICON_FOLDER + "MotionCheck.svg")
	)
	
		# Complex
	add_custom_type(
		"ModulateTransitionButton",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Complex/ModulateTransitionButton.gd"), 
		load(ICON_FOLDER + "ModulateTransitionButton.svg")
	)
	add_custom_type(
		"StyleTransitionButton",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Buttons/Complex/StyleTransitionButton.gd"), 
		load(ICON_FOLDER + "StyleTransitionButton.svg")
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
		# Page
	add_custom_type(
		"Page",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Routers/Page/Page.gd"), 
		load(ICON_FOLDER + "Page.svg")
	)
	
		# RouterSlide
			# BaseRouterTab
	add_custom_type(
		"BaseRouterTab",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterSlide/HelperNodes/Tab/BaseRouterTab.gd"), 
		load(ICON_FOLDER + "BaseRouterTab.svg")
	)
			# RouterTabInfo
	add_custom_type(
		"RouterTabInfo",
		"Resource",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterSlide/HelperNodes/Tab/RouterTabInfo.gd"), 
		null
	)
			# RouterStack
	add_custom_type(
		"RouterSlide",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterSlide/RouterSlide.gd"), 
		load(ICON_FOLDER + "RouterSlide.svg")
	)
	
		# RouterStack
			# PageStackInfo
	add_custom_type(
		"PageStackInfo",
		"Resource",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterStack/PageStackInfo.gd"),
		null
	)
			# RouterStack
	add_custom_type(
		"RouterStack",
		"PanelContainer",
		load(CUSTOM_CLASS_FOLDER + "Routers/RouterStack/RouterStack.gd"), 
		load(ICON_FOLDER + "RouterStack.svg")
	)
	
	# SizeControllers
		# MaxSizeContainer
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "SizeController/MaxSizeContainer.gd"), 
		load(ICON_FOLDER + "MaxSizeContainer.svg")
	)
		# MaxRatioContainer
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
		load(ICON_FOLDER + "SwapContainer.svg")
	)
	
	# TransitionContainers
	add_custom_type(
		"ModulateTransitionContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/ModulateTransitionContainer.gd"), 
		load(ICON_FOLDER + "ModulateTransitionContainer.svg")
	)
	add_custom_type(
		"StyleTransitionContainer",
		"Container",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/StyleTransitionContainer.gd"), 
		load(ICON_FOLDER + "StyleTransitionContainer.svg")
	)
	add_custom_type(
		"StyleTransitionPanel",
		"Panel",
		load(CUSTOM_CLASS_FOLDER + "TransitionContainers/StyleTransitionPanel.gd"), 
		load(ICON_FOLDER + "StyleTransitionPanel.svg")
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

	# AutoSizeLabel
	remove_custom_type("AutoSizeLabel")
	
	# Buttons
		# Base
	remove_custom_type("AnimatedSwitch")
	remove_custom_type("HoldButton")
			# MotionCheck
	remove_custom_type("BoundsCheck")
	remove_custom_type("DistanceCheck")
	remove_custom_type("MotionCheck")
	
		# Complex
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
	remove_custom_type("RouterStack")
		# Base
	remove_custom_type("Page")
	remove_custom_type("PageInfo")
	
	# SizeControllers
	remove_custom_type("MaxSizeContainer")
	remove_custom_type("MaxRatioContainer")
	
	# SwapContainer
	remove_custom_type("SwapContainer")
	
	# TransitionContainers
	remove_custom_type("ModulateTransitionContainer")
	remove_custom_type("StyleTransitionContainer")
	remove_custom_type("StyleTransitionPanel")
