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
var dx, dy, off, slotwid, slothei, items, itemwid, itemhei, itemsx, itemsy;
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
	anislots = 0
	res = null
}

// Background
draw_box(xx, yy, wid, hei, false, setting_color_background, 1)

dx = xx
dy = yy
off = 2

// Number of items
if (anitex = null)
	anislots = 0
items = slots + anislots // Get the total number of active slots in the sheets

// Sizes
slotwid = max(1, floor(texture_width(tex) / slotsx))
slothei = max(1, floor(texture_height(tex) / slotsy))
itemwid = slotwid + off * 2
itemhei = slothei + off * 2
itemsx = floor((wid - 30 * scroll.needed) / itemwid)
itemsy = ceil(items / itemsx)

for (var i = round(scroll.value / itemhei) * itemsx; i < items; i++)
{
	var col, curtex, curslot, curslotsx, curslotsy;
	
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
			col = block_texture_get_blend(mc_version.block_texture_list[|curslot], res)
	}
	else
	{
		curtex = anitex[block_texture_get_frame()]
		curslot = i - slots
		curslotsx = anislotsx
		curslotsy = anislotsy
		if (res)
			col = block_texture_get_blend(mc_version.block_texture_ani_list[|curslot], res)
	}
	
	// Highlight if selected
	if (select = i)
		draw_box(dx, dy, itemwid, itemhei, false, setting_color_highlight, 1)
	
	// Item
	draw_texture_slot(curtex, curslot, dx + off, dy + off, slotwid, slothei, curslotsx, curslotsy, col)
	if (app_mouse_box(dx, dy, itemwid, itemhei) && content_mouseon)
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
	dx += itemwid
	if (dx + itemwid > xx + itemsx * itemwid)
	{
		dx = xx
		dy += itemhei
		if (dy + itemhei > yy + hei)
			break
	}
	
}

// Scrollbar
scroll.snap_value = itemhei
scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 30, yy, floor(hei / itemhei) * itemhei, itemsy * itemhei, setting_color_buttons, setting_color_buttons_pressed, setting_color_background_scrollbar)
