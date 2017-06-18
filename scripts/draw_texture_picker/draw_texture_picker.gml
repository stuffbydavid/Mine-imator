/// draw_texture_picker(select, texture, list, x, y, width, height, slotsx, slotsy, scrollbar, script, [anitexture, anilist, anislotsx, anislotsy, resource])
/// @arg select
/// @arg texture
/// @arg list
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg slotsx
/// @arg slotsy
/// @arg scrollbar
/// @arg script
/// @arg [anitexture
/// @arg anilist
/// @arg anislotsx
/// @arg anislotsy
/// @arg resource]
/// @desc Draws a box for selecting between several images from a static and (optional) animated texture sheet.

var select, tex, list, xx, yy, wid, hei, slotsx, slotsy, scroll, script, anitex, anilist, anislotsx, anislotsy, res;
var dx, dy, off, slotsize, items, itemsize, itemsx, itemsy;
select = argument[0]
tex = argument[1]
list = argument[2]
xx = argument[3]
yy = argument[4]
wid = argument[5]
hei = argument[6]
slotsx = argument[7]
slotsy = argument[8]
scroll = argument[9]
script = argument[10]

if (argument_count > 11)
{
	anitex = argument[11]
	anilist = argument[12]
	anislotsx = argument[13]
	anislotsy = argument[14]
	res = argument[15]
}
else
	res = null

// Background
draw_box(xx, yy, wid, hei, false, setting_color_background, 1)

dx = xx
dy = yy
off = 2

// Number of items
items = ds_list_size(list)
if (argument_count > 11)
	items += ds_list_size(anilist)

// Sizes
slotsize = max(1, floor(texture_width(tex) / slotsx))
itemsize = slotsize + off * 2
itemsx = floor((wid - 30 * scroll.needed) / itemsize)
itemsy = ceil(items / itemsx)

for (var i = round(scroll.value / itemsize) * itemsx; i < items; i++)
{
	var curtex, curslot, curslotsx, curslotsy, name, col;
	
	// Correct name and slot texture
	if (i < ds_list_size(list))
	{
		curtex = tex
		curslot = i
		curslotsx = slotsx
		curslotsy = slotsy
		name = list[|curslot]
	}
	else
	{
		curtex = anitex[block_texture_get_frame()]
		curslot = i - ds_list_size(list)
		curslotsx = anislotsx
		curslotsy = anislotsy
		name = anilist[|curslot]
	}
	
	// Texture color
	col = c_white
	if (res)
		col = block_texture_get_blend(name, res)
		
	// Highlight if selected
	if (select = name)
		draw_box(dx, dy, itemsize, itemsize, false, setting_color_highlight, 1)
	
	// Item
	draw_texture_slot(curtex, curslot, dx + off, dy + off, slotsize, curslotsx, curslotsy, col)
	if (app_mouse_box(dx, dy, itemsize, itemsize) && content_mouseon)
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
	dx += itemsize
	if (dx + itemsize > xx + itemsx * itemsize)
	{
		dx = xx
		dy += itemsize
		if (dy + itemsize > yy + hei)
			break
	}
	
}

// Scrollbar
scroll.snap_value = itemsize
scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid-30, yy, floor(hei / itemsize) * itemsize, itemsy * itemsize, setting_color_buttons, setting_color_buttons_pressed, setting_color_background_scrollbar)
