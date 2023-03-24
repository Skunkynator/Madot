extends Object
class_name TilesetParser


static func parse_element(element : Element) -> Dictionary:
	var tilesets := {}
	var copy := {}
	for tileset_element in element.children:
		var id := tileset_element.attributes.id as String
		tilesets[id] = _parse_tileset(tileset_element)
		if "copy" in tileset_element.attributes:
			copy[id] = tileset_element.attributes.copy
	for id in copy.keys():
		(tilesets[id] as CelesteTileset).rule_copy = tilesets[copy[id]]
	return tilesets


static func _parse_tileset(element : Element) -> CelesteTileset:
	var tileset := CelesteTileset.new()
	var attr := element.attributes
	var id := attr.id as String
	tileset.image_path = attr.path
	# scanWidth/Height are still unstable in everest, but easy enough to implement
	# so we support it for future proofing
	if "scanWidth" in attr:
		tileset.scan_width = attr.scanWidth if attr.scanWidth % 2 == 1 else 3
	if "scanHeight" in attr:
		tileset.scan_height = attr.scanHeight if attr.scanHeight % 2 == 1 else 3
	if "ignores" in attr:
		tileset.set_ignores(attr.ignores)
	for child in element.children:
		if child.name == "set":
			tileset.rules.append(_parse_tilerule(child))
		elif child.name == "define":
			pass# TODO: add define support once its stable in everest
				# too complicated to support without a real use for it yet
	return tileset


static func _parse_tilerule(element : Element) -> CelesteTileset.TileRule:
	var rule := CelesteTileset.TileRule.new()
	var mask := element.attributes.mask as String
	if mask == "center":
		rule.mask_mode = CelesteTileset.TileRule.MaskMode.MaskCenter
	elif mask == "padding":
		rule.mask_mode = CelesteTileset.TileRule.MaskMode.MaskPadding
	# "fillX" mask is still unstable in everest, but we support it for future proofing
	elif mask.begins_with("fill"):
		rule.mask_mode = CelesteTileset.TileRule.MaskMode.MaskFill
		rule.fill_depth = int(mask.substr(5))
	else:
		rule.mask_mode = CelesteTileset.TileRule.MaskMode.MaskScan
		rule.mask = _parse_scan_mask(mask)
	var tiles := (element.attributes.tiles as String).split(";", false)
	for tile in tiles:
		var coords := tile.split(",")
		rule.tiles.append(Vector2i(int(coords[0]), int(coords[1])))
	return rule


static func _parse_scan_mask(mask_str : String) -> PackedByteArray:
	var mask := []
	var regex := RegEx.new()
	regex.compile("[A-Za-z01]") # any letter, 0 or 1
	for res in regex.search_all(mask_str):
		match res.get_string():
			"0":
				mask.append(0)
			"1":
				mask.append(1)
			"x", "X":
				mask.append(2)
			"y", "Y":
				mask.append(3)
			"z", "Z":
				pass # reserved by everest
			var c:
				pass # requires define support
	return mask
