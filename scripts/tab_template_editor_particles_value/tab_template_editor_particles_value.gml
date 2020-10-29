/// tab_template_editor_particles_value(name, value, israndom, randommin, randommax, multiplier, min, max, defaults, snap, textboxes, scripts, [captionwidth, [showcaption, [suffix]]])
/// @arg name
/// @arg value
/// @arg israndom
/// @arg randommin
/// @arg randommax
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg defaults
/// @arg snap
/// @arg textboxes 
/// @arg scripts
/// @arg [captionwidth
/// @arg [showcaption
/// @arg [suffix]]]

var name, val, israndom, randommin, randommax, mul, minval, maxval, def, snapval, tbx, scripts, capwid, showcaption, suffix, wid;
var caption;
name = argument[0]
val = argument[1]
israndom = argument[2]
randommin = argument[3]
randommax = argument[4]
mul = argument[5]
minval = argument[6]
maxval = argument[7]
def = argument[8]
snapval = argument[9]
tbx = argument[10]
scripts = argument[11]

if (argument_count > 12)
	capwid = argument[12]
else
	capwid = null

draw_set_font(font_emphasis)
caption = text_get(name)

if (argument_count > 13)
	showcaption = argument[13]
else
	showcaption = true

if (argument_count > 14)
	suffix = argument[14]
else
	suffix = ""

wid = 64

if (capwid = null)
	capwid = (caption != "" ? string_width(caption) + 8 : 0) * showcaption

tab_control(28)
draw_button_icon("particleeditorrandom" + name, dx + dw - 28, dy, 28, 28, israndom, icons.RANDOM, scripts[1], false, "tooltipparticlesrandom")

if (israndom)
{
	if (showcaption)
	{
		draw_label(caption, dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_emphasis)
		tab_next(false)
		
		tab_control(28)
		capwid = 0
	}
	
	draw_dragger(name + "min", dx + capwid, dy, wid, randommin, mul, minval, randommax, def[1], snapval, tbx[0], scripts[2], null, false)
	capwid += wid + 8
	
	draw_set_font(font_value)
	draw_label(text_get("particleeditorto"), dx + capwid, dy + 14, fa_left, fa_middle, c_text_main, a_text_main)
	capwid += string_width(text_get("particleeditorto")) + 8
	
	draw_dragger(name + "max", dx + capwid, dy, wid, randommax, mul, randommin, maxval, def[2], snapval, tbx[1], scripts[3], null, false)
	capwid += wid + 8
}
else
{
	draw_dragger(name, dx, dy, wid, val, mul, minval, maxval, def[0], snapval, tbx[1], scripts[0], capwid, showcaption)
	capwid += wid + 8
}

if (suffix != "")
	draw_label(suffix, dx + capwid, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)

tab_next()
