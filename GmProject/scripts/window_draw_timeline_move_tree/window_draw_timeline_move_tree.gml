/// window_draw_timeline_move_tree(parent)
/// @arg parent

function window_draw_timeline_move_tree(par)
{
	var itemh, indent, iconcolor, iconalpha, namecolor, namealpha;
	itemh = (setting_timeline_compact ? 20 : 24)
	indent = 20
	
	for (var t = 0; t < ds_list_size(par.tree_list); t++)
	{
		var tl, px, xoff;
		tl = par.tree_list[|t]
		px = dx
		xoff = 0
		
		if (!tl_update_list_filter(tl))
		{
			if (tl.tree_extend)
				window_draw_timeline_move_tree(tl)
			
			continue
		}
		
		dx += 4
		
		if (ds_list_size(tl.tree_list) > 0)
		{
			draw_image(spr_icons, tl.tree_extend ? icons.CHEVRON_DOWN_TINY : icons.CHEVRON_RIGHT_TINY, dx + 8, dy + itemh / 2, 1, 1, c_text_secondary, a_text_secondary)
			
			if (setting_timeline_compact)
				dx += 20
		}
		else if (setting_timeline_compact)
			dx += 5
		
		if (!setting_timeline_compact)
			dx += 20
		
		if (tl.selected)
		{
			iconcolor = c_accent
			iconalpha = 1
			
			namecolor = c_accent
			namealpha = 1
		}
		else
		{
			iconcolor = c_text_tertiary
			iconalpha = a_text_tertiary
			
			namecolor = c_text_main
			namealpha = a_text_main
		}
		
		// Icon
		if (tl.type != null && !setting_timeline_compact)
		{
			draw_image(spr_icons, timeline_icon_list[|tl.type], dx + 10, dy + (itemh/2), 1, 1, iconcolor, iconalpha)
			dx += 28
		}
		
		draw_label(string_remove_newline(tl.display_name), dx, dy + itemh / 2, fa_left, fa_middle, namecolor, namealpha, font_value)
		
		dx = px + indent
		dy += itemh
		
		if (tl.tree_extend)
			window_draw_timeline_move_tree(tl)
		
		dx = px
	}
}
