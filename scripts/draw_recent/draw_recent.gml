/// draw_recent(x, y, width, height, scrollbar)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg scrollbar

var xx, yy, wid, hei, scroll;
var dx, dy, padding, itemh, itemsy;
xx = argument0
yy = argument1
wid = argument2
hei = argument3
scroll = argument4

draw_box(xx, yy, wid, hei, false, setting_color_background, 1)

if (recent_amount = 0)
{
    draw_label(text_get("recentnone"), xx + 10, yy + 10, fa_left, fa_top, null, 1, setting_font_bold)
    return 0
}

dy = yy
padding = 5
itemh = recent_thumbnail_height + padding * 2

for (var r = round(scroll.value / itemh); r < recent_amount; r++)
{
    var dx, dw, name, author, desc;
    var tip, ty, textcol, namewid;
    dx = xx + padding
    dw = wid-30 * scroll.needed
    
    if (dy + itemh > yy + hei)
        break
        
    // Name
    name = recent_name[r]
    if (name = "")
        name = filename_new_ext(filename_name(recent_filename[r]), "")
    name = string_remove_newline(name)
    author = string_remove_newline(recent_author[r])
    desc = string_remove_newline(recent_description[r])
    
    // Tip
    tip = name
    if (author != "")
        tip += " " + text_get("recentauthor", author)
    if (desc != "")
        tip += "\n" + recent_description[r]
    tip_wrap = false
    tip_set(tip, xx, dy, dw, itemh)
        
    // Check mouse
    textcol = setting_color_text
    if (app_mouse_box(xx, dy, dw, itemh))
	{
        mouse_cursor = cr_handpoint
        
        // Close button
        if (draw_button_normal("recentremove", xx + dw - 24, dy + itemh / 2-10, 20, 20, e_button.NO_TEXT, false, false, true, icons.close))
		{
            recent_remove(r)
            r--
            continue
        }
        
        dw -= 28
        
        // Click
        if (app_mouse_box(xx, dy, dw, itemh))
		{
            if (mouse_left)
			{
                textcol = setting_color_highlight_text
                pressed = true
                draw_box(xx, dy, dw, itemh, false, setting_color_highlight, 1)
            }
			
            if (mouse_left_released)
			{
                if (!file_exists_lib(recent_filename[r]))
                    error("erroropenprojectexists")
                else
                    project_open(recent_filename[r])
            }
        }
    }
        
    // Thumbnail
    if (recent_thumbnail[r])
	{
        draw_texture(recent_thumbnail[r], dx, dy + padding)
        dx += recent_thumbnail_width + padding * 2
    }
    
    ty = dy + itemh / 2 - 10 - 10 * (recent_description[r] != "")
    
    // Name
    draw_set_font(setting_font_bold)    
    namewid = string_width(name)
    draw_label(name, dx, ty, fa_left, fa_top, textcol, 1)
    draw_set_font(setting_font)
    
    // Author
    if (author != "")
        draw_label(text_get("recentauthor", author), dx + namewid + 6, ty, fa_left, fa_top, textcol, 1)
      
    // Description
    if (desc != "")
        draw_label(string_limit(desc, dw - (dx - xx)), dx, ty + 18, fa_left, fa_top, textcol, 1)
    
    dy += itemh
}

// Scrollbar
scroll.snap_value = itemh
scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid-30, yy, floor(hei / itemh) * itemh, recent_amount * itemh, setting_color_buttons, setting_color_buttons_pressed, setting_color_background_scrollbar)
