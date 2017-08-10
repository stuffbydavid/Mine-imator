/// block_get_name(block)
/// @arg block

var block = argument0;

if (text_exists("block" + block.name))
	return text_get("block" + block.name)
else
	return string_format_snakecase(block.name)