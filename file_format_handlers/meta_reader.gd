extends BinaryReader
class_name MetaReader


static func read_sprite_atlas(file : FileAccess) -> Dictionary:
	var sprite_atlas : Dictionary = {}
	var current : Dictionary
	file.get_32()
	get_string(file)
	file.get_32()
	for n in file.get_16():
		var atlas_file = get_string(file) + ".data"
		sprite_atlas[atlas_file] = {}
		current = sprite_atlas[atlas_file]
		for sprite in file.get_16():
			parse_sprite(file, current)
	return sprite_atlas


static func parse_sprite(file : FileAccess, current : Dictionary) -> void:
	var sprite := SpriteMetaData.new()
	var path := get_string(file).split("\\")
	sprite.position = Vector2i(file.get_16(), file.get_16())
	sprite.size = Vector2(file.get_16(), file.get_16())
	sprite.offset = Vector2(get_s16(file), get_s16(file)) #negative offset from top left
	sprite.texture_size = Vector2(file.get_16(), file.get_16())
	for i in path.size() - 1:
		if not path[i] in current:
			current[path[i]] = {}
		current = current[path[i]]
	current[path[path.size() - 1]] = sprite
