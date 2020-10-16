/// draw_togglebutton(name, x, y)
/// @arg name
/// @arg x
/// @arg y
/// @desc Displays togglebutton options

var name, xx, yy;
var h, w, buttonx, buttonh, buttoncount, buttonsize, mouseon, script, scriptvalue, axis;
name = argument[0]
xx = argument[1]
yy = argument[2]

h = 52
w = dw

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
{
	togglebutton_reset()
	return 0
}

buttonx = xx
buttonh = 28

buttoncount = array_length_1d(togglebutton_name)
buttonsize = round(w/buttoncount)
mouseon = false
script = null
scriptvalue = null
axis = X

draw_label(text_get(name), xx, yy + 16, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
yy += 24

draw_outline(xx, yy, w, buttonh, 1, c_border, a_border)

draw_set_font(font_button)

for (var i = 0; i < buttoncount; i++)
{	
	mouseon = false
	
	if (app_mouse_box(buttonx, yy, buttonsize, buttonh) && content_mouseon)
		mouseon = true
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name + togglebutton_name[i], null, mouseon, mouseon && mouse_left, togglebutton_active[i])
	
	// Draw base button
	var backgroundcolor, backgroundalpha;
	backgroundcolor = merge_color(c_overlay, c_accent_overlay, mcroani_arr[e_mcroani.PRESS])
	backgroundalpha = lerp(0, a_overlay, min(1.0, mcroani_arr[e_mcroani.HOVER] + mcroani_arr[e_mcroani.ACTIVE]))
	backgroundalpha = lerp(backgroundalpha, a_accent_overlay, mcroani_arr[e_mcroani.PRESS])
	draw_box(buttonx, yy, buttonsize, buttonh, false, backgroundcolor, backgroundalpha)
	
	var labelcolor, labelalpha;
	
	
	var icon = togglebutton_icon[i];
	
	var buttonname, totalwidth, startx;
	buttonname = text_get(togglebutton_name[i])
	totalwidth = string_width(buttonname) + (icon = null ? 0 : 24 + 8)
	startx = snap(buttonx + (buttonsize/2) - (totalwidth/2), 2)
	
	if (buttonname = "")
	{
		totalwidth = 20
		startx = snap(buttonx + (buttonsize/2) - (totalwidth/2), 2)
		
		labelcolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.ACTIVE])
		labelalpha = lerp(a_text_secondary, 1, mcroani_arr[e_mcroani.ACTIVE])
	}
	else
	{
		labelcolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER])
		labelcolor = merge_color(labelcolor, c_accent_pressed, min(1.0, mcroani_arr[e_mcroani.PRESS] + mcroani_arr[e_mcroani.ACTIVE]))
		labelalpha = lerp(1, a_accent_hover, mcroani_arr[e_mcroani.HOVER])
		labelalpha = lerp(labelalpha, a_accent_pressed, min(1.0, mcroani_arr[e_mcroani.PRESS] + mcroani_arr[e_mcroani.ACTIVE]))
	}
	
	// Icon
	if (icon != null)
	{
		draw_image(spr_icons, icon, startx + 10, yy + (buttonh/2), 1, 1, labelcolor, labelalpha)
		startx += 20 + 8
	}
	
	// Text
	draw_label(buttonname, startx, yy + (buttonh/2), fa_left, fa_middle, labelcolor, labelalpha)
	
	if (i > 0)
		draw_box(buttonx, yy + 4, 1, buttonh - 8, false, c_border, a_border)
	
	microani_update(mouseon, mouseon && mouse_left, togglebutton_active[i])
	
	// Execute script with value
	if (mouseon && mouse_left_released)
	{
		if (togglebutton_script[i] != null)
		{
			script = togglebutton_script[i]
			scriptvalue = togglebutton_value[i]
			axis = togglebutton_axis[i]
		}
	}
	
	buttonx += buttonsize
}
buttonx = xx

// Repeat drawing for hover
for (var i = 0; i < buttoncount; i++)
{
	mouseon = false
	
	if (app_mouse_box(buttonx, yy, buttonsize, buttonh) && content_mouseon)
		mouseon = true
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name + togglebutton_name[i], null, mouseon, mouseon && mouse_left, togglebutton_active[i])
	
	draw_box_hover(buttonx, yy, buttonsize, buttonh, mcroani_arr[e_mcroani.HOVER])
	buttonx += buttonsize
}

// Execute script
if (script != null)
{
	axis_edit = axis
	
	if (scriptvalue != null)
		script_execute(script, scriptvalue)
	else
		script_execute(script)
	
	axis_edit = X
}

// Clear togglebutton options
togglebutton_reset()
	