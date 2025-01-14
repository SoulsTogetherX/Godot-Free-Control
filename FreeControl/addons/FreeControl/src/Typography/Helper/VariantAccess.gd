@tool
class_name VariantAccess

## The folder path for all fonts
const FONT_FOLDER = "res://addons/FreeControl/assets/Typographic/NotoSans/"

## All available font weights. If you wish to add or remove a font weight, change this.
enum FONT_WEIGHT {
	ExtraLight,
	Thin,
	Light,
	Regular,
	Medium,
	SemiBold,
	Bold,
	ExtraBold,
	Black,
}
## All available fonts. If you wish to add or remove a preset, edit this.
enum FONT_VARIANT {
	header1,
	header2,
	header3,
	header4,
	header5,
	header6,
	subtitle1,
	subtitle2,
	body1,
	body2,
	button,
	caption,
	overline,
	none,
	custom
}
## The preset data for each [enum FONT_VARIANT]. Change as you need.
const FONT_SETTINGS = {
	FONT_VARIANT.header1: {
		"size": 42,
		"weight": FONT_WEIGHT.Bold,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.header2: {
		"size": 36,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.header3: {
		"size": 24,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.header4: {
		"size": 25,
		"weight": FONT_WEIGHT.Regular,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.header5: {
		"size": 18,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.header6: {
		"size": 17,
		"weight": FONT_WEIGHT.SemiBold,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.subtitle1: {
		"size": 11,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.subtitle2: {
		"size": 10,
		"weight": FONT_WEIGHT.SemiBold,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.body1: {
		"size": 12,
		"weight": FONT_WEIGHT.Regular,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.body2: {
		"size": 11,
		"weight": FONT_WEIGHT.Regular,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.caption: {
		"size": 8,
		"weight": FONT_WEIGHT.Regular,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.button: {
		"size": 12,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": true
	},
	FONT_VARIANT.overline: {
		"size": 12,
		"weight": FONT_WEIGHT.Medium,
		"isItalic": false,
		"caps": false
	},
	FONT_VARIANT.none: {
		"size": 10,
		"weight": FONT_WEIGHT.Regular,
		"isItalic": false,
		"caps": false
	},
}

## Returns the font with the given weight and italics, if it exists in the folder [constant FONT_FOLDER].
static func get_default_font(weight: FONT_WEIGHT, isItalic: bool) -> FontFile:
	return load(
		FONT_FOLDER
		+ FONT_WEIGHT.find_key(weight)
		+ ("Italic.ttf" if isItalic else ".ttf")
	)

## Returns the requested variant preset.
static func get_info(variant : FONT_VARIANT) -> VariantInfo:
	if variant == FONT_VARIANT.custom: return null
	
	var info : Dictionary = FONT_SETTINGS[variant]
	
	var ret := VariantInfo.new()
	ret.variant = variant
	ret.weight = info.weight
	ret.isItalic = info.isItalic
	ret.caps = info.caps
	ret.font = get_default_font(info.weight, info.isItalic)
	ret.size = info.size
	return ret

## The object to whole present variant information
class VariantInfo:
	## The variant id of the present
	var variant : FONT_VARIANT
	## The font weight of the present
	var weight : FONT_WEIGHT
	## If true, the whole text should be in italic
	var isItalic : bool
	## If true, the whole text should be in uppercase
	var caps : bool
	## The font of the present
	var font : FontFile
	## The font size of the present
	var size : int
