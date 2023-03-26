extends BinaryReader
class_name MapReader


static func get_runlength_encoded(file : FileAccess) -> String:
	var size := file.get_16()
	var str := ""
	for i in range(0, size, 2):
		var repetitions := file.get_8()
		str += file.get_buffer(1).get_string_from_ascii().repeat(repetitions)
	return str


static func get_string_array(file : FileAccess) -> Array[String]:
	var count := file.get_16()
	var arr : Array[String] = []
	for i in count:
		arr.append(get_string(file))
	return arr


static func get_lookup_string(file : FileAccess, lookup_table : Array[String]) -> String:
	var index := file.get_16()
	return lookup_table[index]


static func get_encoded(file : FileAccess, lookup_table : Array[String]):
	var type := file.get_8()
	match type:
		0: # Boolean
			return file.get_8() != 0
		1: # Uint 8
			return file.get_8()
		2: # Int 16
			return get_s16(file)
		3: # Int 32
			return get_s32(file)
		4: # Float
			return file.get_float()
		5: # Lookup String
			return get_lookup_string(file, lookup_table)
		6: # String
			return get_string(file)
		7: # Runlength encoded String
			return get_runlength_encoded(file)


static func get_element(file : FileAccess, lookup_table : Array[String]) -> Element:
	var element := Element.new()
	element.name = get_lookup_string(file, lookup_table)
	var attribute_count := file.get_8()
	for i in attribute_count:
		var attribute_name := get_lookup_string(file, lookup_table)
		element.attributes[attribute_name] = get_encoded(file, lookup_table)
	var child_count := file.get_16()
	for i in child_count:
		element.children.append(get_element(file, lookup_table))
	return element


static func get_map(file : FileAccess) -> Element:
	var lookup_table : Array[String]
	if file.get_string() != "CELESTE MAP":
		print("File is not a celeste map")
		return # ERROR
	get_string(file)
	lookup_table = get_string_array(file)
	var root := get_element(file, lookup_table)
	return root
