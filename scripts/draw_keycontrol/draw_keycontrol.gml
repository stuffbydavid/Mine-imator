/// draw_keycontrol(name, x, y, width, key, ctrl, default, script, [captionwidth])
/// @arg x
/// @arg y
/// @arg width
/// @arg key
/// @arg ctrl
/// @arg default
/// @arg script 
/// @arg [captionwidth]

var name, xx, yy, wid, key, ctrl, def, script, capwid;
var hei, text, keystr;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
key = argument[4]
ctrl = argument[5]
def = argument[6]
script = argument[7]

if (argument_count > 8)
    capwid = argument[8]
else
    capwid = text_caption_width(name)

hei = 18
text = text_get(name) + ":"
keystr = text_control_name(key, ctrl)
tip_set(text_get(name + "tip") + "\n" + text_get("keycontroltip"), xx, yy, capwid + string_width(keystr) + 60, hei)

// Check key
if (window_busy = name)
{
    keystr = text_get("keycontrolpress")
    draw_box(xx - 2, yy - 1, wid, hei, false, setting_color_highlight, 1)
    if (mouse_left_pressed || keyboard_check_pressed(vk_escape))
	{
        window_busy = ""
        app_mouse_clear()
    }
	else if (keyboard_check_pressed(vk_anykey))
	{
        keyboard_clear(keyboard_lastkey)
        script_execute(script, keyboard_lastkey)
        window_busy = ""
    }
}

// Click
if (app_mouse_box(xx + capwid, yy, wid - capwid, hei) && content_mouseon)
{
    mouse_cursor = cr_handpoint
    if (mouse_left_pressed)
        window_busy = name
    if (mouse_right_pressed)
        script_execute(script, def)
}

// Label
if (window_busy = name)
    draw_set_color(setting_color_highlight_text)
draw_label(text, xx, yy)
draw_label(keystr, xx + capwid, yy)
if (window_busy = name)
    draw_set_color(setting_color_text)
