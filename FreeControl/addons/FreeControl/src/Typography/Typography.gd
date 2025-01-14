@tool
class_name Typography extends Label
## A label used for consistant font and font size presets

## The font variant preset this label will be using
@export var font_variant : VariantAccess.FONT_VARIANT = VariantAccess.FONT_VARIANT.none:
	set(val):
		if font_variant == val: return
		font_variant = val
		
		if val != VariantAccess.FONT_VARIANT.custom:
			_update_variant(val)
		notify_property_list_changed()
## The text color
@export var font_color : Color = Color.WHITE:
	get:
		return get_theme_color("font_color")
	set(val):
		if font_color != val:
			add_theme_color_override("font_color", val)

@export_group("Font Custom")
var _font_size : int = 16
## The font size. This should only be changed if [member font_variant] is set to [constant VariantAccess.FONT_VARIANT.custom].
var font_size : int:
	get:
		return _font_size
	set(val):
		if _font_size == val: return
		_font_size = val
		add_theme_font_size_override("font_size", val)
var _font_weight : VariantAccess.FONT_WEIGHT = VariantAccess.FONT_WEIGHT.Regular
## The font weight. This should only be changed if [member font_variant] is set to [constant VariantAccess.FONT_VARIANT.custom].
var font_weight : VariantAccess.FONT_WEIGHT:
	get:
		return _font_weight
	set(val):
		if _font_weight == val: return
		_font_weight = val
		add_theme_font_override("font", VariantAccess.get_default_font(val, _italic))
var _italic : bool
## If true, the font will be in italic. This should only be changed if [member font_variant] is set to [constant VariantAccess.FONT_VARIANT.custom].
var italic : bool:
	get:
		return _italic
	set(val):
		if _italic == val: return
		_italic = val
		add_theme_font_override("font", VariantAccess.get_default_font(_font_weight, val))

func _get_property_list() -> Array[Dictionary]:
	if font_variant != VariantAccess.FONT_VARIANT.custom:
		return [];
	
	var properties: Array[Dictionary] = []
	properties.append({
		"name" = "font_size",
		"type" = TYPE_INT,
		"usage" = PROPERTY_USAGE_DEFAULT
	})
	properties.append({
		"name": "font_weight",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": " ,".join(VariantAccess.FONT_WEIGHT.keys())
	})
	properties.append({
		"name" = "italic",
		"type" = TYPE_BOOL,
		"usage" = PROPERTY_USAGE_DEFAULT
	})
	properties.append({
		"name" = "toUpper",
		"type" = TYPE_BOOL,
		"usage" = PROPERTY_USAGE_DEFAULT
	})
	return properties;
func _set(property: StringName, value: Variant) -> bool:
	if property == "toUpper":
		uppercase = value
		return true
	return false
func _get(property: StringName) -> Variant:
	if property == "toUpper": return uppercase
	return null
func _property_can_revert(property: StringName) -> bool:
	match property:
		"font_size":
			return font_size != 16
		"font_weight":
			return _font_weight != VariantAccess.FONT_WEIGHT.Regular
		"italic":
			return _italic
		"toUpper":
			return uppercase
	
	if property in []:
		return true
	return false;
func _property_get_revert(property: StringName) -> Variant:
	match property:
		"font_size":
			return 16
		"font_weight":
			return VariantAccess.FONT_WEIGHT.Regular
		"italic":
			return false
		"toUpper":
			return false
	return null
func _validate_property(property: Dictionary) -> void:
	if property.name == "uppercase":
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _update_variant(variant : VariantAccess.FONT_VARIANT) -> void:
	var info := VariantAccess.get_info(variant)
	
	_font_size = info.size
	_font_weight = info.weight
	_italic = info.isItalic
	uppercase = info.caps
	
	begin_bulk_theme_override()
	add_theme_font_override("font", info.font)
	add_theme_font_size_override("font_size", info.size)
	end_bulk_theme_override()
