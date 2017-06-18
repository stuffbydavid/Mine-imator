/// language_load(filename, map)
/// @arg filename
/// @arg map

var fn, map, f, key;
fn = argument0
map = argument1

log("Load language file", fn)

ds_map_clear(map)

file_delete_lib(temp_file)
file_copy_lib(fn, temp_file)
f = file_text_open_read(temp_file)
if (f > -1)
{
    while (!file_text_eof(f))
	{
        var line, pos, text;
        line = file_text_readln(f)
        line = string_copy(line, 1, string_length(line) - 2)
        pos = string_pos(":", line)
        if (pos = 0)
            continue
        text = string_copy(line, 1, pos - 1)
        pos++
        while (string_char_at(line, pos) = " ")
            pos++
		map[? text] = string_delete(line, 1, pos - 1)
    }
    file_text_close(f)
}

if (map != language_english_map) // Add missing words
{
    log("Adding missing words")
    f = file_text_open_append(temp_file)
    if (f > -1)
	{
        key = ds_map_find_first(language_english_map)
        for (var w = 0; w < ds_map_size(language_english_map); w++)
		{
            if (!ds_map_exists(map, key))
			{
                file_text_write_string(f, key + ": " + ds_map_find_value(language_english_map, key))
                file_text_writeln(f)
				map[? key] = ds_map_find_value(language_english_map, key)
            }
            key = ds_map_find_next(language_english_map, key)
        }
        file_text_close(f)
    }
    file_copy_lib(temp_file, fn)
}
