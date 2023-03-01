extends Object
class_name MapReader


static func get_string(file : FileAccess) -> String:
	var length := 0
	var str := ""
	var str_start := false
	var i := 0
	while not str_start:
		var byte : int = file.get_8()
		str_start = (byte & 0b10000000) == 0
		length += (byte & 0b01111111) << (7 * i)
		i += 1
	return file.get_buffer(length).get_string_from_ascii()


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


static func short_to_signed(unsigned : int) -> int:
	return (unsigned + (1 << 15)) % (1 << 16) - (1 << 15)


static func int_to_signed(unsigned : int) -> int:
	return (unsigned + (1 << 31)) % (1 << 32) - (1 << 31)


static func get_encoded(file : FileAccess, lookup_table : Array[String]):
	var type := file.get_8()
	match type:
		0: # Boolean
			return file.get_8() != 0
		1: # Uint 8
			return file.get_8()
		2: # Int 16
			return short_to_signed(file.get_16())
		3: # Int 32
			return int_to_signed(file.get_32())
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


static func read_map_file(path : String) -> Element:
	var lookup_table : Array[String]
	var file := FileAccess.open(path,FileAccess.READ)
	if get_string(file) != "CELESTE MAP":
		print("File is not a celeste map")
		return # ERROR
	get_string(file)
	lookup_table = get_string_array(file)
	var root := get_element(file, lookup_table)
	return root
