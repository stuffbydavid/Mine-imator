/// action_build_search()

function action_build_search()
{
	if (build_first_person)
		action_build_first_person(false)

	tab_show(build_tool, true)
	textbox_lastfocus = -1
	window_focus = string(build_tool.build_list.search_tbx)
	textbox_input = ""
}
