/// json_export_start(filename)
/// @arg filename
/// @desc Starts exporting formatted JSON to a text file.

globalvar json_filename, json_indent, json_empty, json_add_comma;
json_filename = argument0
json_indent = 0
json_empty = true
json_add_comma = false

enum e_json_char {
	TAB				= ord("\t"),
	NEW_LINE		= ord("\n"),
	COMMA			= ord(","),
	COLON			= ord(":"),
	QUOTE			= ord("\""),
	SPACE			= ord(" "),
	CURLY_BEGIN		= ord("{"),
	CURLY_END		= ord("}"),
	SQUARE_BEGIN	= ord("["),
	SQUARE_END		= ord("]")
}

buffer_current = buffer_create(8, buffer_grow, 1)
