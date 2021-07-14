/// list_item_draw(item, x, y, width, height, [toggled, [margin, [xoffset, [animation]]]])
/// @arg item
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [toggled
/// @arg [margin
/// @arg [xoffset
/// @arg [animation]]]
/// @desc Draws a list item with icons/buttons

function list_item_draw()
{
	var item, xx, yy, width, height, toggled, margin, xoffset, components, animation, name;
	var leftp, rightp, middley, mousehover, hover, scissor;
	item = argument[0]
	xx = argument[1]
	yy = argument[2]
	width = argument[3]
	height = argument[4]
	toggled = false
	margin = 0
	xoffset = 0
	components = 0
	animation = true
	
	if (item.list != null && item.list.get_name)
		name = text_get(item.name)
	else
		name = item.name
	
	if (argument_count > 5)
		toggled = argument[5]
	
	if (item.toggled)
		toggled = true
	
	if (argument_count > 6)
		if (argument[6] != null)
			margin = argument[6]
	
	margin = 0
	
	if (argument_count > 7)
		if (argument[7] != null)
			xoffset = argument[7]
	
	if (argument_count > 8)
		animation = argument[8]
	
	if (xx + width < content_x || xx > content_x + content_width || yy + height < content_y || yy > content_y + content_height)
		return 0
	
	if (item.list != null && item.list.update)
		return 0
	
	item.draw_x = xx
	item.draw_y = yy
	
	// Draw divider below item
	if (item.divider)
		draw_divide(xx + 4, yy - 4, width - 8)
	
	var textcolor, textalpha, iconcolor, iconalpha, backcolor, backalpha, focus;
	
	if (animation)
	{
		microani_set(string(item), "", item.hover, item.hover && mouse_left && item.interact, toggled && item.interact, item.disabled)
		microani_update(item.hover, item.hover && mouse_left && item.interact, toggled && item.interact, item.disabled)
		
		focus = max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS])
		
		textcolor = merge_color(c_text_main, c_accent, focus)
		textcolor = merge_color(textcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		textalpha = lerp(a_text_main, a_accent, focus)
		textalpha = lerp(textalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		iconcolor = merge_color(c_text_tertiary, c_accent, focus)
		iconcolor = merge_color(iconcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		iconalpha = lerp(a_text_tertiary, a_accent, focus)
		iconalpha = lerp(iconalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		backcolor = merge_color(c_overlay, c_accent_overlay, focus)
		backalpha = lerp(0, a_overlay, microani_arr[e_microani.HOVER])
		backalpha = lerp(backalpha, a_accent_overlay, focus)
		
		draw_box(xx, yy, width, height, false, backcolor, backalpha)
		draw_box_hover(xx, yy, width, height, microani_arr[e_microani.PRESS])
	}
	else
	{
		textcolor = c_text_main
		textalpha = a_text_main
		iconcolor = c_text_tertiary
		iconalpha = a_text_tertiary
		backcolor = c_black
		backalpha = 0
	}
	
	leftp = margin
	rightp = margin
	middley = yy + height/2
	mousehover = app_mouse_box(xx, yy, width, height) && !item.disabled && content_mouseon
	hover = mousehover
	
	leftp += (item.indent + xoffset)
	
	if (leftp < 0)
	{
		scissor = true
		scissor_start(xx, yy, width, height)
	}
	else
		scissor = false
	
	// Image/icon size
	var imgsize, iconsize;
	imgsize = height - 8
	iconsize = max(imgsize, 24)
	
	if (item.thumbnail)
	{
		if (height <= 24)
			leftp += 8
		else
			leftp += 4
		
		if (item.thumbnail_backdrop)
			draw_box(xx + leftp, middley - imgsize/2, imgsize, imgsize, false, c_level_bottom, 1)
		
		draw_image(item.thumbnail, 0, xx + leftp, middley - imgsize/2, imgsize / texture_width(item.thumbnail), imgsize / texture_height(item.thumbnail), item.thumbnail_blend, item.thumbnail_alpha)
		
		if (height > 24)
			leftp += imgsize - 4
		else	
			leftp += imgsize
		
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
	if (item.icon_left != null && item.icon_left != -1)
	{
		leftp += 4
		
		draw_image(spr_icons, item.icon_left, xx + leftp + iconsize/2, middley, 1, 1, iconcolor, iconalpha)
		leftp += (iconsize - 4)
		components++
	}
	
	// Right actions
	if (item.actions_right != null)
	{
		for (var i = 0; i < ds_list_size(item.actions_right); i += 7)
		{
			rightp += 4// * (components > 0)
			
			if (draw_button_icon(item.actions_right[|i], (xx + width - rightp) - 20, middley - 10, 20, 20, item.actions_right[|i + 1], item.actions_right[|i + 3], null, false, item.actions_right[|i + 5], item.actions_right[|i + 6]))
				script_execute(item.actions_right[|i + 4], item.actions_right[|i + 2])
			
			hover = (hover && !app_mouse_box((xx + width - rightp) - 20, middley - 10, 20, 20))
			rightp += 16
			components++
		}
	}
	
	// Right icon
	if (item.icon_right != null)
	{
		rightp += 4
		
		if (item.icon_right != -1)
			draw_image(spr_icons, item.icon_right, (xx + width - rightp) - iconsize/2, middley, 1, 1, iconcolor, iconalpha)
		
		rightp += 24
		components++
	}
	
	// Toggled tick
	if (item.list != null && item.list.toggled)
	{
		rightp += 4
		
		if (toggled)
			draw_image(spr_icons, icons.TICK, (xx + width - rightp) - iconsize/2, middley, 1, 1, iconcolor, iconalpha)
		
		rightp += 24
		components++
	}
	
	// Caption
	if (item.caption != "")
	{
		rightp += 8
	
		draw_set_font(font_caption)
		draw_label(item.caption, xx + width - rightp, middley, fa_right, fa_middle, c_text_tertiary, a_text_tertiary)
		rightp += string_width(item.caption)
	}
	
	//if ((leftp > (margin + item.indent + xoffset)))
	//	leftp += 12
	//else
	//	leftp += 4
	
	// Text
	leftp += 8 + (4 * (height > 24))
	
	draw_set_font(font_value)
	
	var textwidth = width - (leftp + rightp) - 8;
	draw_label(string_limit(name, textwidth), xx + leftp, middley, fa_left, fa_middle, textcolor, textalpha)
	
	if (scissor)
		scissor_done()
	
	item.hover = hover
	if (hover && item.interact)
		mouse_cursor = cr_handpoint
	
	if (item.script && hover && mouse_left_released)
	{
		list_item_script = item.script
		list_item_script_value = item.value
		list_item_value = context_menu_value
	}
}
