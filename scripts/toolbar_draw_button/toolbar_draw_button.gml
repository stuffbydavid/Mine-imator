/// toolbar_draw_button(name, pressed, enabled, icon, script, [tip])
/// @arg name
/// @arg pressed
/// @arg enabled
/// @arg icon
/// @arg script
/// @arg [tip]

var name, pressed, enabled, icon, script, tip;
name = argument[0]
pressed = argument[1]
enabled = argument[2]
icon = argument[3]
script = argument[4]

if (argument_count > 5)
	tip = argument[5]
else
	tip = text_get(name + "tip")

if (draw_button_normal(name, dx, dy, 28, 28, e_button.NO_TEXT, pressed, false, enabled, icon, c_white, tip))
	script_execute(script)

dx += 30
if (dx + 30 > content_x + content_width)
{
	dx = content_x
	dy += 30
}
