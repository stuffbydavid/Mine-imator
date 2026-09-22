/// sortlist_search_default(sortlist, value, search)

function sortlist_search_default(slist, value, search)
{
	for (var c = 0; c < slist.columns; c++)
		if (string_contains(string_lower(string(sortlist_column_get(slist, value, c))), search))
			return 2
	
	return 0
}
