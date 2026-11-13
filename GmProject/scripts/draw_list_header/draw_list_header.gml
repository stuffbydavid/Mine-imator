/// @desc Draws the list header and returns whether its parent container is visible.
/// @arg sortlist
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [filter]
/// @arg [name]
/// @arg [value]

function draw_list_header(list, xx, yy, wid, hei, filter = true, name = "", value = null)
{
	list.search_changed = false

	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	{
		if (textbox_jump)
			ds_list_add(textbox_list, [list.search_tbx, content_tab, yy, content_y, content_height])
		
		return false
	}

	var searchx, searchwid, ispicker;
	ispicker = (list.object_index = obj_picker)
	searchwid = max(1, wid - (ispicker ? 28 : 0))
	if (filter || name != "")
		searchwid = min(144, searchwid)
	searchx = xx + wid - (ispicker ? 28 : 0) - searchwid

	// Filter menu
	if (filter)
	{
		if (draw_button_icon("list/filter" + string(list), xx, yy, 24, 24, !ds_list_empty(list.filter_list), icons.FILTER, null, false, "tooltip/filter_list"))
		{
			menu_settings_set(xx, yy, "list/filter" + string(list), 24)
			settings_menu_script = sortlist_filters_draw
			settings_menu_sortlist = list
			settings_menu_h_max = 256
			settings_menu_scroll.value = list.filter_scroll
			settings_menu_scroll.value_goal = list.filter_scroll
		}

		if (settings_menu_name = "list/filter" + string(list) && settings_menu_ani_type != "hide")
			current_microani.active.value = true
	}

	// Label and search box, including its clear button
	if (name != "")
	{
		var namex, namewid;
		namex = xx + (filter ? 32 : 0)
		namewid = max(0, searchx - namex - 8 - (list.search_tbx.text != "" ? 28 : 0))
		if (value != null)
			draw_label_value(namex, yy, namewid, 24, name, value)
		else
		{
			draw_set_font(font_label)
			draw_label(string_limit(name, namewid), namex, yy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		}
	}

	list.search_changed = draw_searchbox("list/search" + string(list), searchx, yy, searchwid, list.search_tbx, !filter && name = "")
	if (list.search_changed)
	{
		list.search = (list.search_tbx.text != "")
		list.scroll.value = 0
		list.scroll.value_goal = 0
		sortlist_update(list)
	}

	// Switch between grid and list
	if (ispicker && draw_button_icon("list/view" + string(list), xx + wid - 24, yy, 24, 24, false, list.grid_view ? icons.COMPACT : icons.GRID_VIEW, null, false, list.grid_view ? "tooltip/list_view" : "tooltip/grid_view"))
	{
		list.grid_view = !list.grid_view
		list.view_value = null
		list.center_on_draw = true
	}

	return true
}
