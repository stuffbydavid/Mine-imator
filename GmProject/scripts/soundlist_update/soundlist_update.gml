/// soundlist_update(soundlist)

function soundlist_update(slist)
{
	var search, row;
	ds_list_clear(slist.display_list)
	search = string_lower(slist.search_tbx.text)
	for (var i = 0; i < ds_list_size(slist.list); i++)
	{
		row = slist.list[|i]
		if (!ds_list_empty(slist.filter_list) && ds_list_find_index(slist.filter_list, row[0]) < 0)
			continue

		if (search != "" && !string_contains(string_lower(row[1]), search))
			continue

		ds_list_add(slist.display_list, row)
	}
}
