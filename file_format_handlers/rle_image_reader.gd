extends Object
class_name RleImageReader
# Run Length Encoded images are the image format used in vanilla celeste

static func read_image_file(path : String) -> Image:
	var file := FileAccess.open(path,FileAccess.READ)
	var width := file.get_32()
	var height := file.get_32()
	var transparent := file.get_8() != 0
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var colour := Color()
	var repetitions : int
	var pos : int = 0
	while not file.eof_reached():
		repetitions = file.get_8()
		colour.a8 = file.get_8() if transparent else 255
		colour.b8 = file.get_8() if colour.a8 != 0 else 0
		colour.g8 = file.get_8() if colour.a8 != 0 else 0
		colour.r8 = file.get_8() if colour.a8 != 0 else 0
		for i in repetitions:
			img.set_pixel(pos % width, pos / width, colour)
			pos += 1
	return img
