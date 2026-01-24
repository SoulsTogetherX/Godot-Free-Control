# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends EditorPlugin

func _enter_tree() -> void:
	# AnimatableControls
		# Control
	add_custom_type(
		"AnimatableControl",
		"Container",
		load("uid://bdebqplr7au8q"),
		load("uid://bq0lhbd2ta2e8")
	)
	add_custom_type(
		"AnimatablePositionalControl",
		"Container",
		load("uid://0i5secg3em7k"),
		load("uid://4tsqbmjbowum")
	)
	add_custom_type(
		"AnimatableScrollControl",
		"Container",
		load("uid://c7in16lfr4lx6"),
		load("uid://b6osyfr4ww5xn")
	)
	add_custom_type(
		"AnimatableZoneControl",
		"Container",
		load("uid://c1bjrg3xbnp1f"),
		load("uid://dngia4pggibje")
	)
	add_custom_type(
		"AnimatableVisibleControl",
		"Container",
		load("uid://bhcb3ijflvfwj"),
		load("uid://bc2unp7gcrn1b")
	)
		# Mount
	add_custom_type(
		"AnimatableMount",
		"Control",
		load("uid://bikr31ssqqgxe"),
		load("uid://daxpji6uv1g46")
	)
	add_custom_type(
		"AnimatableTransformationMount",
		"Control",
		load("uid://clu5ifocno1fc"),
		load("uid://cotvxfxb3vswy")
	)

	# AutoSizeLabels
		# AutoSizeLabel
	add_custom_type(
		"AutoSizeLabel",
		"Label",
		load("uid://v0ehje2clt8q"),
		load("uid://dq34kjc4fapt4")
	)
	
	# Buttons
		# Base
	add_custom_type(
		"AnimatedSwitch",
		"BaseButton",
		load("uid://ba40c75ghd5jn"),
		load("uid://cagqaca7g37hu")
	)
	add_custom_type(
		"HoldButton",
		"Control",
		load("uid://cxpavl8t4pjda"),
		load("uid://d2tx1trtvayki")
	)
			# MotionCheck
	add_custom_type(
		"BoundsCheck",
		"Control",
		load("uid://bmarfghi5ygvt"),
		load("uid://cyim00qnkag0s")
	)
	add_custom_type(
		"DistanceCheck",
		"Control",
		load("uid://dxfjq3ihql3b8"),
		load("uid://dk23pvtfisnr1")
	)
	add_custom_type(
		"MotionCheck",
		"Control",
		load("uid://dalcaavf4vj2w"),
		load("uid://cs6768dpea36w")
	)
	
		# Complex
	add_custom_type(
		"ModulateTransitionButton",
		"Container",
		load("uid://cbavvc7w51o1e"),
		load("uid://dcsh4v2wd0gxd")
	)
	add_custom_type(
		"StyleTransitionButton",
		"Container",
		load("uid://8jyk6thl41yx"),
		load("uid://d2f0h0csexl37")
	)
	
	# Carousel
	add_custom_type(
		"Carousel",
		"Container",
		load("uid://dl8gv5mo2s7ce"),
		load("uid://b0boo7h5iafbu")
	)
	
	# CircularContainer
	add_custom_type(
		"CircularContainer",
		"Container",
		load("uid://dy227jqsnl5sw"),
		load("uid://dkm1xiqpo4cms")
	)
	
	# Drawer
	add_custom_type(
		"Drawer",
		"Container",
		load("uid://bqll335fobepk"),
		load("uid://c0hu6q3b2n6im")
	)
	
	# PaddingContainer
	add_custom_type(
		"PaddingContainer",
		"Container",
		load("uid://dube6kmp8e6dk"),
		load("uid://mgfp36i5f8fb")
	)
	
	# Routers
		# Page
	add_custom_type(
		"Page",
		"Container",
		load("uid://est7fe85qyrr"),
		load("uid://baajocq0otlbt")
	)
	
		# RouterSlide
			# BaseRouterTab
	add_custom_type(
		"BaseRouterSlideTab",
		"Container",
		load("uid://cpfk05hayu1bi"),
		load("uid://cmhybg2uglq8g")
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
		load("uid://c4rat7q035412")
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
		load("uid://d04agqiqsbw4f")
	)
	
	# SizeControllers
		# MaxSizeContainer
	add_custom_type(
		"MaxSizeContainer",
		"Container",
		load("uid://qyynh24u37dl"),
		load("uid://cas71sna8pvfd")
	)
		# MaxRatioContainer
	add_custom_type(
		"MaxRatioContainer",
		"Container",
		load("uid://dxat85kl81ij8"),
		load("uid://gx7wjtdyu0kx")
	)
	
	# SwapContainer
	add_custom_type(
		"SwapContainer",
		"Container",
		load("uid://xy6iej3vgplw"),
		load("uid://dlmlimt80wyed")
	)
	
	# TransitionContainers
	add_custom_type(
		"ModulateTransitionContainer",
		"Container",
		load("uid://pgglabrqqqf8"),
		load("uid://frrreb5gdmcc")
	)
	add_custom_type(
		"StyleTransitionContainer",
		"Container",
		load("uid://dpxv0jw7hjhta"),
		load("uid://cvy6f5pfxqkao")
	)
	add_custom_type(
		"StyleTransitionPanel",
		"Panel",
		load("uid://b1byk6qaj6eg4"),
		load("uid://i20h00snyguv")
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
