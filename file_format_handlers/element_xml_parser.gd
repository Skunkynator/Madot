extends XMLParser
class_name ElementXMLParser


func get_element_safe() -> Element:
	read()
	while get_node_type() != NODE_ELEMENT:
		read()
	return get_element()


func get_element() -> Element:
	var element := Element.new()
	element.name = get_node_name()
	for i in get_attribute_count():
		var attr_name = get_attribute_name(i)
		element.attributes[attr_name] = get_attribute_value(i)
	if is_empty():
		return element
	while read() == OK:
		var type = get_node_type()
		if get_node_type() == NODE_ELEMENT_END:
			break
		if get_node_type() == NODE_ELEMENT:
			element.children.append(get_element())
	var type = get_node_type()
	var empty = is_empty()
	return element
