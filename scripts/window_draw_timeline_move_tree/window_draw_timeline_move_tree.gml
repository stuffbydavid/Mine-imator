/// window_draw_timeline_move_tree(parent)
/// @arg parent

var par, itemh, indent;
par = argument0
itemh = (setting_timeline_compact ? 18 : 24)
indent = 16

for (var t = 0; t < ds_list_size(par.tree_list); t++)
{
	var tl, px, xoff;
	tl = par.tree_list[|t]
	px = dx
	xoff = 0
	
	if (ds_list_size(tl.tree_list) > 0)
	{
		draw_image(spr_icons, tl.tree_extend ? icons.ARROW_DOWN_TINY : icons.ARROW_RIGHT_TINY, dx + 2, dy + itemh / 2, 1, 1, setting_color_text, 1)
		xoff = 10
	}
	
	draw_label(string_remove_newline(tl.display_name), dx + xoff, dy + itemh / 2, fa_left, fa_middle, null, 1, tl.selected ? setting_font_bold : setting_font)
	
	dx += indent
	dy += itemh
	
	if (tl.tree_extend)
		window_draw_timeline_move_tree(tl)
		
	dx = px
}
