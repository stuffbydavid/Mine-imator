/// text_exists(key)
/// @arg key

function text_exists(key)
{
	return ds_map_exists(language_english_map, key)
}
