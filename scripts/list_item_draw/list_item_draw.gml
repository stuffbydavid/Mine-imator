/// list_item_draw(item, x, y, width, height, [toggled, [margin, [xoffset]]])
/// @arg item
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [toggled
/// @arg [margin
/// @arg [xoffset]]]
/// @desc Draws a list item with icons/buttons

var item, xx, yy, width, height, toggled, margin, xoffset, components, name;
var leftp, rightp, middley, mousehover, hover, textcolor, textalpha, iconcolor, iconalpha;
item = argument[0]
xx = argument[1]
yy = argument[2]
width = argument[3]
height = argument[4]
toggled = false
margin = 12
xoffset = 0
components = 0

if (item.list != null && item.list.get_name)
	name = text_get(item.name)
else
	name = item.name

if (argument_count > 5)
	toggled = argument[5]

if (argument_count > 6)
	margin = argument[6]

if (argument_count > 7)
	xoffset = argument[7]

if (xx + width < content_x || xx > content_x + content_width || yy + height < content_y || yy > content_y + content_height)
	return 0

if (item.list != null && item.list.update)
	return 0

item.draw_x = xx
item.draw_y = yy

if (item.divider)
	draw_divide(xx, yy - 4, width - 1)

if (item.disabled)
{
	textcolor = c_text_tertiary
	textalpha = a_text_tertiary
	iconcolor = c_text_tertiary
	iconalpha = a_text_tertiary
}
else if ((toggled || (item.hover && mouse_left) || (item.hover && mouse_left_released)) && item.interact)
{
	textcolor = c_accent
	textalpha = a_accent
	iconcolor = c_accent
	iconalpha = a_accent
}
else
{
	textcolor = c_text_main
	textalpha = a_text_main
	iconcolor = c_text_tertiary
	iconalpha = a_text_tertiary
}

if (item.hover && mouse_left && item.interact)
	draw_box(xx, yy, width, height, false, c_accent_overlay, a_accent_overlay)
else if ((item.hover || toggled || (item.hover && mouse_left_released)) && item.interact)
	draw_box(xx, yy, width, height, false, c_overlay, a_overlay)

leftp = margin
rightp = margin
middley = yy + height/2
mousehover = app_mouse_box(xx, yy, width, height) && !item.disabled && content_mouseon
hover = mousehover

leftp += (item.indent + xoffset)

// Thumbnail
if (item.thumbnail)
{
	var thumbsize = height - 8;
	draw_image(item.thumbnail, 0, xx + leftp, middley - thumbsize/2, thumbsize / texture_width(item.thumbnail), thumbsize / texture_height(item.thumbnail), item.thumbnail_blend, item.thumbnail_alpha)
	leftp += thumbsize
	components++
}

// Left actions
if (item.actions_left != null)
{
	for (var i = 0; i < ds_list_size(item.actions_left); i += 7)
	{
		leftp += 4 * (components > 0)
		
		if (draw_button_icon(item.actions_left[|i], xx + leftp, middley - 10, 20, 20, item.actions_left[|i + 1], item.actions_left[|i + 3], null, false, item.actions_left[|i + 5], item.actions_left[|i + 6]))
			script_execute(item.actions_left[|i + 4], item.actions_left[|i + 2])
		
		hover = (hover && !app_mouse_box(xx + leftp, middley - 10, 20, 20))
		leftp += 20
		components++
	}
}

// Left icon
if (item.icon_left != null)
{
	leftp += 4 * (components > 0)
	
	if (item.icon_left != -1)
		draw_image(spr_icons, item.icon_left, xx + leftp + 10, middley, 1, 1, iconcolor, iconalpha)
	
	leftp += 20
}

components = 0

// Right actions
if (item.actions_right != null)
{
	for (var i = 0; i < ds_list_size(item.actions_right); i += 7)
	{
		rightp += 4 * (components > 0)
		
		if (draw_button_icon(item.actions_right[|i], (xx + width - rightp) - 20, middley - 10, 20, 20, item.actions_right[|i + 1], item.actions_right[|i + 3], null, false, item.actions_right[|i + 5], item.actions_right[|i + 6]))
			script_execute(item.actions_right[|i + 4], item.actions_right[|i + 2])
		
		hover = (hover && !app_mouse_box((xx + width - rightp) - 20, middley - 10, 20, 20))
		rightp += 20
		components++
	}
}

// Right icon
if (item.icon_right != null)
{
	rightp += 4 * (components > 0)
	
	if (item.icon_right != -1)
		draw_image(spr_icons, item.icon_right, (xx + width - rightp) - 10, middley, 1, 1, iconcolor, iconalpha)
	
	rightp += 20
	components++
}

// Caption
if (item.caption != "")
{
	rightp += 4
	
	draw_set_font(font_caption)
	draw_label(item.caption, xx + width - rightp, middley, fa_right, fa_center, c_text_tertiary, a_text_tertiary)
	rightp += string_width(item.caption)
}

if (leftp > (margin + item.indent + xoffset))
	leftp += 12

// Text
draw_set_font(font_value)

var textwidth = width - (leftp + rightp) - 8;
draw_label(string_limit(name, textwidth), xx + leftp, middley, fa_left, fa_middle, textcolor, textalpha)

item.hover = hover
if (hover && item.interact)
	mouse_cursor = cr_handpoint

if (item.script && hover && mouse_left_released)
{
	if (item.value != null)
		script_execute(item.script, item.value)
	else
		script_execute(item.script)
}