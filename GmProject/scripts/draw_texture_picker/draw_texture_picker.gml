/// draw_texture_picker(select, textures, slots, sheet_sizes, x, y, width, height, scrollbar, script, [namelists, resource, selectclick, searchstretch])
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
/// @arg resource
/// @arg selectclick]
/// @arg searchstretch]
/// @desc Draws a box for selecting between images from several texture sheets.
///		  The sheets share a single 32px grid. The script receives a combined slot
///		  number, whose offsets are the preceding sheet list sizes.

function draw_texture_picker(select, texlist, slots, sheetsizes, xx, yy, wid, hei, scroll, script, namelists = null, res = null, scriptselectclick = null, searchstretch = false)
{
	var off, slotwid, slothei, itemwid, itemhei, itemsx, contenthei, displaycount;
	var pickermouseon, searchchanged, previoustipslot, slotoffset;
	var searchx, searchwid, searchtext;

	searchx = xx + wid - 144
	searchwid = 144
	if (searchstretch)
	{
		searchx = xx
		searchwid = wid
	}
	searchchanged = draw_searchbox("texturesearch" + string(scroll), searchx, yy, searchwid, scroll.search_tbx, searchstretch)
	if (searchchanged)
	{
		scroll.search = scroll.search_tbx.text != ""
		scroll.search_slots = null
		scroll.value = 0
		scroll.value_goal = 0
	}

	if (scroll.search && scroll.search_slots = null)
	{
		var searchslots;
		searchslots = array_create(0)
		searchtext = string_lower(scroll.search_tbx.text)
		slotoffset = 0
		for (var sheet = 0; sheet < array_length(slots); sheet++)
		{
			var names;
			names = (namelists != null && sheet < array_length(namelists)) ? namelists[sheet] : null
			if (ds_list_valid(names))
			{
				for (var slot = 0; slot < min(slots[sheet], ds_list_size(names)); slot++)
				{
					var slotname;
					slotname = string_lower(names[|slot])
					if (string_pos(searchtext, slotname) > 0 || string_pos(string_replace_all(searchtext, " ", "_"), slotname) > 0)
						array_add(searchslots, slotoffset + slot)
				}
			}
			slotoffset += slots[sheet]
		}
		scroll.search_slots = searchslots
	}

	yy += 32
	hei -= 32
	if (hei <= 0)
		return 0
	
	// Background
	draw_box(xx + 1, yy + 1, wid - 2, hei - 2, false, c_input_background, draw_get_alpha())
	
	// Outline
	if (window_focus = string(scroll))
	{
		draw_outline(xx, yy, wid, hei, 1, c_accent, 1, true)
		window_scroll_focus = string(scroll)

		if (!app_mouse_box(xx, yy, wid, hei) && content_mouseon && mouse_left && window_busy != "scrollbar")
			window_focus = ""
	}
	else
		draw_outline(xx, yy, wid, hei, 1, c_border, a_border, true)
	
	off = 1
	slotwid = 32
	slothei = 32
	itemwid = slotwid + off * 2
	itemhei = slothei + off * 2
	itemsx = max(1, floor((wid - 14 * scroll.needed) / itemwid))
	displaycount = scroll.search ? array_length(scroll.search_slots) : 0
	if (!scroll.search)
		for (var sheet = 0; sheet < array_length(slots); sheet++)
			displaycount += slots[sheet]
	contenthei = ceil(displaycount / itemsx) * itemhei
	pickermouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	previoustipslot = scroll.picker_tip_slot
	scroll.picker_tip_slot = -1

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

	var firstslot, lastslot;
	firstslot = clamp(floor(scroll.value / itemhei) * itemsx, 0, displaycount)
	lastslot = clamp(ceil((scroll.value + hei) / itemhei) * itemsx, 0, displaycount)

	shader_texture_filter_linear = false
	draw_texture_start()
	for (var displayslot = firstslot; displayslot < lastslot; displayslot++)
	{
		var combinedslot, sheet, slot, tex, sheetsize, tx, ty, col;
		combinedslot = scroll.search ? scroll.search_slots[displayslot] : displayslot
		sheet = 0
		slot = combinedslot
		while (sheet < array_length(slots) && slot >= slots[sheet])
		{
			slot -= slots[sheet]
			sheet++
		}
		if (sheet >= array_length(slots))
			continue

		tex = texlist[sheet]
		sheetsize = sheetsizes[sheet]
		if (tex = null || sheetsize[X] <= 0 || sheetsize[Y] <= 0)
			continue

		tx = xx + (displayslot mod itemsx) * itemwid
		ty = floor(yy - scroll.value + (displayslot div itemsx) * itemhei)

		col = c_white
		if (res != null && namelists != null && ds_list_valid(namelists[sheet]))
			col = block_texture_get_blend(namelists[sheet][|slot], res)

		// Keep the selection behind the cell texture
		if (select = combinedslot)
		{
			draw_texture_done()
			draw_box(tx, ty, itemwid, itemhei, false, c_accent_hover, a_accent_hover)
			draw_texture_start()
		}

		draw_texture_slot(tex, slot, tx + off, ty + off, slotwid, slothei, sheetsize[X], sheetsize[Y], col, true)
		if (pickermouseon && app_mouse_box(tx, ty, itemwid, itemhei))
		{
			if (previoustipslot != combinedslot)
				scroll.picker_tip_time = current_time
			scroll.picker_tip_slot = combinedslot
			if (namelists != null && ds_list_valid(namelists[sheet]) && slot < ds_list_size(namelists[sheet]))
			{
				if (current_time - scroll.picker_tip_time >= 250)
					tip_set(minecraft_texture_get_name(namelists[sheet][|slot]), tx, ty, itemwid, itemhei)
			}

			mouse_cursor = cr_handpoint
			if (mouse_left_pressed)
			{
				if (combinedslot = select && window_focus = string(scroll) && scriptselectclick != null)
				{
					script_execute(scriptselectclick)
					if (scriptselectclick = action_bench_create)
					{
						bench_show_ani_type = "hide"
						app_mouse_clear()
					}
				}
				else
					script_execute(script, combinedslot)

				// Restore drawing after the selection callback updates a preview
				draw_texture_start()
				window_focus = string(scroll)
				select = combinedslot
			}
		}
	}
	draw_texture_done()
	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
	
	// Scrollbar
	scroll.snap_value = itemhei
	scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 12, yy, hei, contenthei)
}
