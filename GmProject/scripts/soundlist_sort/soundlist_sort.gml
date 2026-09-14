/// soundlist_sort(list)

function soundlist_sort(list)
{
	var rows, keys, index, val, key, digits;
	rows = ds_list_create()
	keys = ds_list_create()
	digits = 0
	
	ds_list_copy(rows, list)
	for (var i = 0; i < ds_list_size(rows); i++)
	{
		val = rows[|i];
		digits = max(digits, string_natural_digits(val[1]))
	}

	for (var i = 0; i < ds_list_size(rows); i++)
	{
		index = string(i)
		val = rows[|i]
		key = string_natural_value(string_lower(val[1]), digits) + chr(1) + string_repeat("0", 8 - string_length(index)) + index
		ds_list_add(keys, key)
	}

	ds_list_sort(keys, true)
	ds_list_clear(list)
	
	for (var i = 0; i < ds_list_size(keys); i++)
	{
		key = keys[|i]
		index = eval(string_copy(key, string_length(key) - 7, 8), 0)
		ds_list_add(list, rows[|index])
	}

	ds_list_destroy(rows)
	ds_list_destroy(keys)
}
