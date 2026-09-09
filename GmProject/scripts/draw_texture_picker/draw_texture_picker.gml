/// draw_texture_picker(select, textures, slots, sheet_sizes, x, y, width, height, scrollbar, script, [namelists, resource])
/// @arg select
/// @arg textures
/// @arg slots
/// @arg sheet_sizes
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg scrollbar
/// @arg script
/// @arg [namelists
/// @arg resource]
/// @desc Draws a box for selecting between images from several texture sheets.
///		  The sheets are stacked as separate grids. The script receives a combined slot
///		  number, whose offsets are the preceding sheet list sizes.

function draw_texture_picker(select, texlist, slots, sheetsizes, xx, yy, wid, hei, scroll, script, namelists = null, res = null)
{
	var off, contenthei, slotoffset, scrollsnap;
	
	// Outline
	draw_outline(xx, yy, wid, hei, 1, c_border, a_border)
	
	off = 1
	contenthei = 0
	slotoffset = 0
	scrollsnap = 0

	var clipactive, clipx, clipy, clipwid, cliphei;
	clipactive = shader_clip_active
	if (clipactive)
	{
		clipx = shader_clip_x
		clipy = shader_clip_y
		clipwid = shader_clip_width
		cliphei = shader_clip_height
	}
	clip_begin(xx + 1, yy + 1, wid - 14 * scroll.needed - 1, hei - 2)

	for (var sheet = 0; sheet < array_length(slots); sheet++)
	{
		var tex, slotcount, sheetsize, slotwid, slothei, itemwid, itemhei, itemsx, itemsy;
		tex = texlist[sheet]
		slotcount = slots[sheet]
		sheetsize = sheetsizes[sheet]
		if (tex = null || slotcount <= 0 || sheetsize[X] <= 0 || sheetsize[Y] <= 0)
		{
			slotoffset += slotcount
			continue
		}
		
		slotwid = clamp(floor(texture_width(tex) / sheetsize[X]), 16, 64)
		slothei = clamp(floor(texture_height(tex) / sheetsize[Y]), 16, 64)
		itemwid = slotwid + off * 2
		itemhei = slothei + off * 2
		if (scrollsnap = 0)
			scrollsnap = itemhei
		itemsx = max(1, floor((wid - 14 * scroll.needed) / itemwid))
		itemsy = ceil(slotcount / itemsx)
		
		var firstslot, lastslot;
		firstslot = clamp(floor((scroll.value - contenthei) / itemhei) * itemsx, 0, slotcount)
		lastslot = clamp(ceil((scroll.value + hei - contenthei) / itemhei) * itemsx, 0, slotcount)
		for (var slot = firstslot; slot < lastslot; slot++)
		{
			var tx, ty, col, combinedslot;
			tx = xx + (slot mod itemsx) * itemwid
			ty = floor(yy + contenthei - scroll.value + (slot div itemsx) * itemhei)
			combinedslot = slotoffset + slot

			col = c_white
			if (res != null && namelists != null && ds_list_valid(namelists[sheet]))
				col = block_texture_get_blend(namelists[sheet][|slot], res)

			if (shader_clip_active)
				clip_begin()

			if (select = combinedslot)
				draw_box(tx - off, ty - off, slotwid + off * 4, slothei + off * 4, false, c_accent_hover, a_accent_hover)

			draw_texture_slot(tex, slot, tx + off, ty + off, slotwid, slothei, sheetsize[X], sheetsize[Y], col)
			if (app_mouse_box(tx, ty, itemwid, itemhei) && content_mouseon)
			{
				mouse_cursor = cr_handpoint
				if (mouse_left_pressed)
				{
					script_execute(script, combinedslot)
					window_focus = string(scroll)
					select = combinedslot
				}
			}
		}
		
		contenthei += itemsy * itemhei
		slotoffset += slotcount
	}
	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
	
	// Scrollbar
	scroll.snap_value = max(1, scrollsnap)
	scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 12, yy, hei, contenthei)
}
