extends Object
class_name BinaryReader


static func get_string(file : FileAccess) -> String:
	var length := get_7(file)
	var str := ""
	return file.get_buffer(length).get_string_from_ascii()


static func get_7(file : FileAccess) -> int:
	var val := 0
	var i := 0
	while true:
		var byte : int = file.get_8()
		val += (byte & 0b01111111) << (7 * i)
		if (byte & 0b10000000) == 0:
			break
		i += 1
	return val


static func get_s16(file : FileAccess) -> int:
	return (file.get_16() + (1 << 15)) % (1 << 16) - (1 << 15)


static func get_s32(file : FileAccess) -> int:
	return (file.get_32() + (1 << 31)) % (1 << 32) - (1 << 31)
