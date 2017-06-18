/// tab_template_editor_particles_value(name, value, israndom, randommin, randommax, multiplier, min, max, defaults, snap, textboxes, scripts, [captionwidth])
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
/// @arg [captionwidth]

var name, val, israndom, randommin, randommax, mul, minval, maxval, def, snapval, tbx, scripts, capwid;
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
    capwid = text_caption_width(name)

tab_control_dragger()
draw_checkbox("particleeditorrandom", dx + dw - 75, dy + 2, israndom, scripts[1])

if (israndom)
{
    var wid = capwid + string_width(string(randommin) + tbx[0].suffix) + 5;
    draw_dragger(name, dx, dy, wid, randommin, mul, minval, randommax, def[1], snapval, tbx[0], scripts[2], capwid)
    draw_dragger(name + "random", dx + wid, dy, dw - 80 - wid, randommax, mul, randommin, maxval, def[2], snapval, tbx[1], scripts[3], text_caption_width(name + "random") - 15, text_get(name + "tip"))
}
else
    draw_dragger(name, dx, dy, dw - 80, val, mul, minval, maxval, def[0], snapval, tbx[0], scripts[0], capwid)

tab_next()
