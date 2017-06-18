/// menu_draw()
/// @desc Draws the dropdown menu.


// Animation
if (menu_ani_type = "hide") //Hide
{
    menu_ani -= 0.1 * delta
    if (menu_ani <= 0)
	{
        menu_ani = 0
        menu_name = ""
        menu_clear()
        return 0
    }
}
else if (menu_ani_type = "show") //Show
{
    menu_ani += 0.1 * delta
    if (menu_ani >= 1)
	{
        menu_ani = 1
        menu_ani_type = ""
    }
}

if (menu_name = "")
    return 0

if (menu_type = e_menu.TRANSITION_LIST)
{
    itemsx = floor((menu_w - 30 * menu_scroll.needed) / menu_item_w)
    itemsy = ceil(menu_amount / itemsx)
}
else
{
    itemsx = 1
    itemsy = menu_amount
}

var yy, h;
h = ease(test(menu_ani_type = "show", "easeoutexpo", "easeinexpo"), menu_ani) * min(itemsy, menu_show) * menu_item_h
yy = test(menu_flip, menu_y - h, menu_y + menu_button_h)

draw_drop_shadow(menu_x, yy, menu_w, h)
draw_box_rounded(menu_x, yy, menu_w, h, setting_color_buttons, 1, menu_flip, menu_flip, !menu_flip, !menu_flip)

content_x = menu_x
content_y = yy
content_width = menu_w
content_height = h

if (window_busy = "menu")
    window_busy = ""

// Scrollbar
content_mouseon = app_mouse_box(menu_x, yy, menu_w, h)
if (menu_ani_type = "")
{
    menu_scroll.snap_value = menu_item_h
    scrollbar_draw(menu_scroll, e_scroll.VERTICAL, menu_x + menu_w - 30, yy, h, itemsy * menu_item_h, setting_color_buttons_text, setting_color_buttons_text, setting_color_buttons_pressed)
}

var mouseitem = null;
switch (menu_type)
{
    case e_menu.LIST: // Normal list with images and caption
	{
        var dy = yy;
        for (var m = round(menu_scroll.value / menu_item_h); m < menu_amount; m++)
		{
            var item, imgsize, dx, highlight, text;
            
            if (dy + menu_item_h > yy + h)
                break
            
            item = menu_item[m]
            imgsize = menu_item_h - 4
            dx = menu_item_h / 2
            
            if (app_mouse_box(menu_x, dy, menu_w - 30 * menu_scroll.needed, menu_item_h))
			{
                mouseitem = item
                mouse_cursor = cr_handpoint
            }
            
            // Highlight box
            highlight = (menu_value = item.value || (mouseitem = item && (mouse_left || mouse_left_released)))
            if (highlight)
                draw_box(menu_x, dy, menu_w - 30 * menu_scroll.needed, menu_item_h, false, setting_color_highlight, 1)
            
            // Sprite
            if (item.icon)  //Icons
                draw_image(spr_icons, item.icon, menu_x + imgsize / 2+4, dy + menu_item_h / 2, 1, 1, test(highlight, setting_color_highlight_text, setting_color_buttons_text), 1)
            else if (item.tex)
                draw_texture(item.tex, menu_x + 4, dy + 2, imgsize / texture_width(item.tex), imgsize / texture_height(item.tex))
            
            // Caption
            dx += test(item.icon || item.tex, imgsize - 4, 0)
            text = string_limit(item.text, menu_w - 30 * menu_scroll.needed - 8-dx)
            draw_label(text, menu_x + dx, dy + menu_item_h / 2, fa_left, fa_middle, test(highlight, setting_color_highlight_text, setting_color_buttons_text), 1)
            dy += menu_item_h
        }
        break
    }
	
    case e_menu.TIMELINE: // List of the timeline
	{
        var indent, dy;
        indent = 16
        dy = yy
        
        for (var m = round(menu_scroll.value / menu_item_h); m < menu_amount; m++)
		{
            var item, tl, dx, highlight, text, hasextend, extendmouseon;
            
            if (dy + menu_item_h > yy + h)
                break
            
            item = menu_item[m]
            tl = item.value
            dx = 12 + item.level * indent
            
            // Check mouse
            hasextend = false
            extendmouseon = false
            if (tl != app && tl.tree_amount - (tl_edit.parent = tl && !menu_include_tl_edit) > 0 && dx + 10 < menu_w)
			{
                hasextend = true
                extendmouseon = app_mouse_box(menu_x, dy, dx + 10, menu_item_h)
            }
            if (app_mouse_box(menu_x, dy, menu_w - 30 * menu_scroll.needed, menu_item_h))
			{
                mouse_cursor = cr_handpoint
                if (!extendmouseon)
				{
                    mouseitem = item
                    mouseval = tl
                }
            }
            
            // Highlight box
            highlight = (menu_value = tl || (mouseitem = item && (mouse_left || mouse_left_released)))
            if (highlight)
                draw_box(menu_x, dy, menu_w - 30 * menu_scroll.needed, menu_item_h, false, setting_color_highlight, 1)
            
            // Extend arrows
            if (hasextend)
			{
                if (extendmouseon && mouse_left_released)
				{
                    app_mouse_clear()
                    action_tl_extend(tl)
                    menu_clear()
                    menu_timeline_init()
                }
                draw_image(spr_icons, test(tl.tree_extend, icons.arrowdowntiny, icons.arrowrighttiny), menu_x + dx + 2, dy + menu_item_h / 2, 1, 1, test(highlight, setting_color_highlight_text, setting_color_buttons_text), 1)
                dx += 10
            }
            
            // Caption
            if (tl = app)
                text = text_get("timelinenone")
            else
                text = string_remove_newline(tl.display_name)
            draw_label(string_limit(text, menu_w - 30 * menu_scroll.needed - dx), menu_x + dx, dy + menu_item_h / 2, fa_left, fa_middle, test(highlight, setting_color_highlight_text, setting_color_buttons_text), 1)
            dy += menu_item_h
        }
        break
    }
	
    case e_menu.TRANSITION_LIST: // Transition list
	{
        var dx, dy;
        dx = menu_x
        dy = yy
        
        for (var m = round(menu_scroll.value / menu_item_h) * itemsx; m < menu_amount; m++)
		{
            var item, highlight;
            
            if (dy + menu_item_h > yy + h)
                break
                
            item = menu_item[m]
            
            // Check mouse
            if (app_mouse_box(dx, dy, menu_item_h, menu_item_h))
			{
                var name = ds_list_find_value(transition_list, item.value)
                window_busy = ""
                tip_set(text_get("transition" + name), dx, dy, menu_item_w, menu_item_h)
                mouseitem = item
                mouseval = item.value
                mouse_cursor = cr_handpoint
            }
            
            // Highlight box
            highlight = (menu_value = item.value || (mouseitem = item && (mouse_left || mouse_left_released)))
            if (highlight)
                draw_box(dx, dy, menu_item_w, menu_item_h, false, setting_color_highlight, 1)
    
            // Texture
            draw_texture(transition_texture[item.value], dx, dy, 1, 1, test(highlight, setting_color_highlight_text, setting_color_buttons_text), 1)
            
            // Iterate
            dx += menu_item_w
            if (dx + menu_item_h > menu_x + itemsx * menu_item_h)
			{
                dx = menu_x
                dy += menu_item_h
            }
        }
        break
	}
}

// Check click
if (!app_mouse_box(menu_x + menu_w - 30, yy, 30 * menu_scroll.needed, h) && mouse_left_released)
{
    menu_ani = 1
    menu_ani_type = "hide"
    window_busy = ""
    if (mouseitem)
	{
        menu_ani = 2
        menu_value = mouseitem.value
        temp_edit = menu_temp_edit
        if (menu_type = e_menu.TIMELINE)
            script_execute(menu_script, menu_value, 0)
        else
            script_execute(menu_script, menu_value)
        app_mouse_clear()
    }
}

if (window_busy = "" && menu_ani_type != "hide")
    window_busy = "menu"
