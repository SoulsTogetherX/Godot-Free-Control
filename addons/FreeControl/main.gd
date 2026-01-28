# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends EditorPlugin

const ICON_FOLDER := "res://addons/FreeControl/assets/icons/CustomType/"

func _enter_tree() -> void:
	# AnimatableControls
		# Control
	add_custom_type(
		"AnimatableControl",
		"Container",
		load("uid://bdebqplr7au8q"),
		load(ICON_FOLDER + "AnimatableControl.svg")
	)
	add_custom_type(
		"AnimatablePositionalControl",
		"Container",
		load("uid://0i5secg3em7k"),
		load(ICON_FOLDER + "AnimatablePositionalControl.svg")
	)
	add_custom_type(
		"AnimatableScrollControl",
		"Container",
		load("uid://c7in16lfr4lx6"),
		load(ICON_FOLDER + "AnimatableScrollControl.svg")
	)
	add_custom_type(
		"AnimatableZoneControl",
		"Container",
		load("uid://c1bjrg3xbnp1f"),
		load(ICON_FOLDER + "AnimatableZoneControl.svg")
	)
	add_custom_type(
		"AnimatableVisibleControl",
		"Container",
		load("uid://bhcb3ijflvfwj"),
		load(ICON_FOLDER + "AnimatableVisibleControl.svg")
	)
		# Mount
	add_custom_type(
		"AnimatableMount",
		"Control",
		load("uid://bikr31ssqqgxe"),
		load(ICON_FOLDER + "AnimatableMount.svg")
	)
	add_custom_type(
		"AnimatableTransformationMount",
		"Control",
		load("uid://clu5ifocno1fc"),
		load(ICON_FOLDER + "AnimatableTransformationMount.svg")
	)

	# AutoSizeLabels
		# AutoSizeLabel
	add_custom_type(
		"AutoSizeLabel",
		"Label",
		load("uid://v0ehje2clt8q"),
		load(ICON_FOLDER + "AutoSizeLabel.svg")
	)
	
	# Buttons
		# Base
	add_custom_type(
		"AnimatedSwitch",
		"BaseButton",
		load("uid://ba40c75ghd5jn"),
		load(ICON_FOLDER + "AnimatedSwitch.svg")
	)
	add_custom_type(
		"HoldButton",
		"Control",
		load("uid://cxpavl8t4pjda"),
		load(ICON_FOLDER + "HoldButton.svg")
	)
			# MotionCheck
	add_custom_type(
		"BoundsCheck",
		"Control",
		load("uid://bmarfghi5ygvt"),
		load(ICON_FOLDER + "BoundsCheck.svg")
	)
	add_custom_type(
		"DistanceCheck",
		"Control",
		load("uid://dxfjq3ihql3b8"),
		load(ICON_FOLDER + "DistanceCheck.svg")
	)
	add_custom_type(
		"MotionCheck",
		"Control",
		load("uid://dalcaavf4vj2w"),
		load(ICON_FOLDER + "MotionCheck.svg")
	)
	
		# Complex
	add_custom_type(
		"ModulateTransitionButton",
		"Container",
		load("uid://cbavvc7w51o1e"),
		load(ICON_FOLDER + "ModulateTransitionButton.svg")
	)
	add_custom_type(
		"StyleTransitionButton",
		"Container",
		load("uid://8jyk6thl41yx"),
		load(ICON_FOLDER + "StyleTransitionButton.svg")
	)
	
	# Carousel
	add_custom_type(
		"Carousel",
		"Container",
		load("uid://dl8gv5mo2s7ce"),
		load(ICON_FOLDER + "Carousel.svg")
	)
	
	# CircularContainer
	add_custom_type(
		"CircularContainer",
		"Container",
		load("uid://dy227jqsnl5sw"),
		load(ICON_FOLDER + "CircularContainer.svg")
	)
	
	# Drawer
	add_custom_type(
		"Drawer",
		"Container",
		load("uid://bqll335fobepk"),
		load(ICON_FOLDER + "Drawer.svg")
	)
	
	# PaddingContainer
	add_custom_type(
		"PaddingContainer",
		"Container",
		load("uid://dube6kmp8e6dk"),
		load(ICON_FOLDER + "PaddingContainer.svg")
	)
	
	# Routers
		# Page
	add_custom_type(
		"Page",
		"Container",
		load("uid://est7fe85qyrr"),
		load(ICON_FOLDER + "Page.svg")
	)
	
		# RouterSlide
			# BaseRouterTab
	add_custom_type(
		"BaseRouterSlideTab",
		"Container",
		load("uid://cpfk05hayu1bi"),
		load(ICON_FOLDER + "BaseRouterSlideTab.svg")
	)
			# Resources
				# RouterSlideInfo
	add_custom_type(
		"RouterSlideInfo",
		"Resource",
		load("uid://cpwhcce1ebaje"),
		null
	)
				# RouterSlidePageInfo
	add_custom_type(
		"RouterSlidePageInfo",
		"Resource",
		load("uid://bswnl1ijx5cov"),
		null
	)
			# RouterStack
	add_custom_type(
		"RouterSlide",
		"Container",
		load("uid://3jrwrwipf7l2"),
		load(ICON_FOLDER + "RouterSlide.svg")
	)
	
		# RouterStack
			# PageStackInfo
	add_custom_type(
		"PageStackInfo",
		"Resource",
		load("uid://cfg60vxnnbwgf"),
		null
	)
			# RouterStack
	add_custom_type(
		"RouterStack",
		"PanelContainer",
		load("uid://c2ao0xk5wpenk"),
		load(ICON_FOLDER + "RouterStack.svg")
	)
	
	# SizeControllers
		# MaxSizeContainer
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load("uid://qyynh24u37dl"),
		load(ICON_FOLDER + "MaxSizeContainer.svg")
	)
		# MaxRatioContainer
	add_custom_type(
		"MaxRatioContainer",
		"Container",
		load("uid://dxat85kl81ij8"),
		load(ICON_FOLDER + "MaxRatioContainer.svg")
	)
	
	# SwapContainer
	add_custom_type(
		"SwapContainer",
		"Container",
		load("uid://xy6iej3vgplw"),
		load(ICON_FOLDER + "SwapContainer.svg")
	)
	
	# TransitionContainers
	add_custom_type(
		"ModulateTransitionContainer",
		"Container",
		load("uid://pgglabrqqqf8"),
		load(ICON_FOLDER + "ModulateTransitionContainer.svg")
	)
	add_custom_type(
		"StyleTransitionContainer",
		"Container",
		load("uid://dpxv0jw7hjhta"),
		load(ICON_FOLDER + "StyleTransitionContainer.svg")
	)
	add_custom_type(
		"StyleTransitionPanel",
		"Panel",
		load("uid://b1byk6qaj6eg4"),
		load(ICON_FOLDER + "StyleTransitionPanel.svg")
	)

func _exit_tree() -> void:
	# AnimatableControls
		# Control
	remove_custom_type("AnimatableControl")
	remove_custom_type("AnimatablePositionalControl")
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
	
	# Routers
		# Page
	remove_custom_type("Page")
		# RouterSlide
			# BaseRouterTab
	remove_custom_type("BaseRouterSlideTab")
			# Resources
				# RouterSlideInfo
	remove_custom_type("RouterSlideInfo")
				# RouterSlidePageInfo
	remove_custom_type("RouterSlidePageInfo")
			# RouterStack
	remove_custom_type("RouterSlide")
	
		# RouterStack
			# PageStackInfo
	remove_custom_type("PageStackInfo")
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
