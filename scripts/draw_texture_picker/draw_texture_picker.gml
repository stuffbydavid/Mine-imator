/// draw_texture_picker(select, texture, x, y, width, height, slots, slotsx, slotsy, scrollbar, script, [anitexture, anislots, anislotsx, anislotsy, resource])
/// @arg select
/// @arg texture
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg slots
/// @arg slotsx
/// @arg slotsy
/// @arg scrollbar
/// @arg script
/// @arg [anitexture
/// @arg anislots
/// @arg anislotsx
/// @arg anislotsy
/// @arg resource]
/// @desc Draws a box for selecting between several images from a static and (optional) animated texture sheet.
///		  The script is called when a slot is selected from any of the sheets.

var select, tex, xx, yy, wid, hei, slots, slotsx, slotsy, scroll, script, anitex, anislots, anislotsx, anislotsy, res;
var tx, ty, off, slotwid, slothei, items, itemwid, itemhei, itemsx, itemsy;
select = argument[0]
tex = argument[1]
xx = argument[2]
yy = argument[3]
wid = argument[4]
hei = argument[5]
slots = argument[6]
slotsx = argument[7]
slotsy = argument[8]
scroll = argument[9]
script = argument[10]

if (argument_count > 11)
{
	anitex = argument[11]
	anislots = argument[12]
	anislotsx = argument[13]
	anislotsy = argument[14]
	res = argument[15]
}
else
{
	anitex = null
	res = null
}

// Outline
draw_outline(xx, yy, wid, hei, 1, c_border, a_border)

tx = xx
ty = yy
off = 2

// Get number of  active slots in the sheets
if (anitex = null)
	items = slots 
else
	items = slots + anislots

// Sizes
slotwid = clamp(floor(texture_width(tex) / slotsx), 16, 64)
slothei = clamp(floor(texture_height(tex) / slotsy), 16, 64)
itemwid = slotwid + off * 2
itemhei = slothei + off * 2
itemsx = floor((wid - 14 * scroll.needed) / itemwid)
itemsy = ceil(items / itemsx)

for (var i = round(scroll.value / itemhei) * itemsx; i < items; i++)
{
	var col, curtex, curslot, curslotsx, curslotsy;
	
	draw_box(tx + off, ty + off, slotwid, slothei, false, c_background_secondary, 1)
	
	// Texture color
	col = c_white
	
	// Correct name and slot texture
	if (i < slots)
	{
		curtex = tex
		curslot = i
		curslotsx = slotsx
		curslotsy = slotsy
		if (res)
			col = block_texture_get_blend(mc_assets.block_texture_list[|curslot], res)
	}
	else
	{
		curtex = anitex[block_texture_get_frame(true)]
		curslot = i - slots
		curslotsx = anislotsx
		curslotsy = anislotsy
		if (res)
			col = block_texture_get_blend(mc_assets.block_texture_ani_list[|curslot], res)
	}
	
	// Highlight if selected
	if (select = i)
	{
		//draw_box(tx, ty, itemwid, itemhei, false, c_accent_overlay, a_accent_overlay)
		draw_outline(tx + off, ty + off, slotwid, slothei, 2, c_accent, 1)
	}
	
	// Item
	draw_texture_slot(curtex, curslot, tx + off, ty + off, slotwid, slothei, curslotsx, curslotsy, col)
	if (app_mouse_box(tx, ty, itemwid, itemhei) && content_mouseon)
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			script_execute(script, i)
			window_focus = string(scroll)
			select = i
		}
	}
	
	// Advance
	tx += itemwid
	if (tx + itemwid > xx + itemsx * itemwid)
	{
		tx = xx
		ty += itemhei
		
		if (ty + itemhei > yy + hei)
			break
	}
	
}

// Scrollbar
scroll.snap_value = itemhei
scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 12, yy, floor(hei / itemhei) * itemhei, itemsy * itemhei)

