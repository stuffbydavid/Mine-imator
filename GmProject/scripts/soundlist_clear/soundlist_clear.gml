/// soundlist_clear(soundlist)

function soundlist_clear(slist)
{
	ds_list_clear(slist.list)
	ds_list_clear(slist.display_list)
	ds_list_clear(slist.filter_list)
	slist.search_tbx.text = ""
	slist.search = false
	slist.scroll.value = 0
	slist.scroll.value_goal = 0
}
