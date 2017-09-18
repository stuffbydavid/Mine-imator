/// json_startup()

globalvar json_type_map, json_char, json_value, json_value_type, json_column, json_line, json_error;
globalvar json_filename, json_indent, json_empty, json_add_comma;

enum e_json_char
{
	CURLY_BEGIN		= ord("{"),
	CURLY_END		= ord("}"),
	SQUARE_BEGIN	= ord("["),
	SQUARE_END		= ord("]"),
	COMMA			= ord(","),
	COLON			= ord(":"),
	QUOTE			= ord("\""),
	SPACE			= ord(" "),
	TAB				= ord("\t"),
	NEW_LINE		= ord("\n"),
	RETURN			= ord("\r"),
	POINT			= ord("."),
	MINUS			= ord("-"),
	PLUS			= ord("+"),
	BACKSLASH		= ord("\\"),
	F				= ord("f"),
	N				= ord("n"),
	T				= ord("t"),
	U				= ord("u"),
	NUM_0			= ord("0"),
	NUM_9			= ord("9")
}

enum e_json_type
{
	NUMBER,
	STRING,
	BOOL,
	NULL,
	ARRAY,
	OBJECT
}
