/// draw_texture_picker(select, texture, list, x, y, width, height, slotsx, scrollbar, script, [anitexture, anilist, anislotsx, resource])
/// @arg select
/// @arg texture
/// @arg list
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg slotsx
/// @arg scrollbar
/// @arg script
/// @arg [anitexture
/// @arg anilist
/// @arg anislotsx
/// @arg resource]
/// @desc Draws a box for selecting between several images from a static and (optional) animated texture sheet.

var select, tex, list, xx, yy, wid, hei, slotsx, scroll, script, anitex, anilist, anislotsx, res;
var dx, dy, off, slots, itemsize, slotsize, itemsx, itemsy;
select = argument[0]
tex = argument[1]
list = argument[2]
xx = argument[3]
yy = argument[4]
wid = argument[5]
hei = argument[6]
slotsx = argument[7]
scroll = argument[8]
script = argument[9]

if (argument_count > 10)
{
	anitex = argument[10]
	anilist = argument[11]
	anislotsx = argument[12]
	res = argument[13]
}
else
	res = null

// Background
draw_box(xx, yy, wid, hei, false, setting_color_background, 1)

dx = xx
dy = yy
off = 2

// Number of slots
slots = ds_list_size(list)
if (argument_count > 10)
	slots += ds_list_size(anilist)

// Sizes
itemsize = min(64, texture_width(tex) / slotsx)
slotsize = itemsize + off * 2
itemsx = floor((wid - 30 * scroll.needed) / slotsize)
itemsy = ceil(slots / itemsx)

for (var s = round(scroll.value / slotsize) * itemsx; s < slots; s++)
{
	var curtex, curslot, curslotsx, name, col;
	
	// Correct name and slot texture
	if (s < ds_list_size(list))
	{
		curtex = tex
		curslot = s
		curslotsx = slotsx
		name = list[|curslot]
	}
	else
	{
		curtex = anitex[block_texture_get_frame()]
		curslot = s - ds_list_size(list)
		curslotsx = anislotsx
		name = anilist[|curslot]
	}
	
	// Texture color
	col = c_white
	if (res)
		col = block_texture_get_blend(name, res)
		
	// Highlight if selected
	if (select = name)
		draw_box(dx, dy, slotsize, slotsize, false, setting_color_highlight, 1)
	
	// Slot
	draw_texture_slot(curtex, curslot, dx + off, dy + off, itemsize, curslotsx, col)
	if (app_mouse_box(dx, dy, slotsize, slotsize) && content_mouseon)
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			script_execute(script, name)
			window_focus = string(scroll)
			select = name
		}
	}
	
	// Advance
	dx += slotsize
	if (dx + slotsize > xx + itemsx * slotsize)
	{
		dx = xx
		dy += slotsize
		if (dy + slotsize > yy + hei)
			break
	}
	
}

// Scrollbar
scroll.snap_value = slotsize
scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid-30, yy, floor(hei / slotsize) * slotsize, itemsy * slotsize, setting_color_buttons, setting_color_buttons_pressed, setting_color_background_scrollbar)
