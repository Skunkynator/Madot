extends RefCounted
class_name CelesteTileset


class TileRule:
	enum MaskMode {MaskScan, MaskPadding, MaskCenter, MaskFill}
	var mask_mode : MaskMode
	var mask : PackedByteArray
	var fill_depth : int
	var tiles : Array[Vector2i]


var scan_width := 3
var scan_height := 3
var image_path : String
var rule_copy : CelesteTileset
var rules : Array[TileRule] = []
var ignores_all := false
var ignores : Array[String] = []


func get_full_rules() -> Array[TileRule]:
	var combined_rules : Array[TileRule] = rules
	if rule_copy:
		combined_rules.append_array(rule_copy.get_rules())
	return combined_rules


func set_ignores(new_ignore : String) -> void:
	ignores_all = new_ignore == "*"
	ignores = []
	var regex := RegEx.new()
	regex.compile("(?<=^|,).(?=,|$)") # any single character surrounded by , or edge of string
	for res in regex.search_all(new_ignore):
		ignores.append(res.get_string())
