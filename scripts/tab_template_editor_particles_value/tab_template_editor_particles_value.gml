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

function tab_template_editor_particles_value()
{
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
	
	draw_set_font(font_label)
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
	
	tab_control_dragger()
	draw_button_icon("particleeditorrandom" + name, dx + dw - 24, dy, 24, 24, israndom, icons.RANDOMIZE, scripts[1], false, "tooltipparticlesrandom")
	
	var suf1, suf2;
	suf1 = tbx[0].suffix
	suf2 = tbx[1].suffix
	tbx[0].suffix += suffix
	tbx[1].suffix += suffix
	
	if (israndom)
	{
		if (showcaption)
		{
			draw_label(caption, dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
			tab_next(false)
			
			tab_control_textfield_group(false)
			dy += 2
			
			capwid = 0
		}
		
		textfield_group_add(name + "min", randommin, def[1], scripts[2], X, tbx[0], null, mul, minval, randommax, "particleeditormin")
		textfield_group_add(name + "max", randommax, def[2], scripts[3], X, tbx[1], null, mul, randommin, maxval, "particleeditormax")
		draw_textfield_group(name, dx, dy, dw - (32 * !showcaption), null, null, null, snapval, false)
	}
	else
	{
		draw_dragger(name, dx, dy, dragger_width, val, mul, minval, maxval, def[0], snapval, tbx[1], scripts[0], (dw - (dragger_width + 24 + 8)), showcaption)
		capwid += wid + 8
	}
	
	tbx[0].suffix = suf1
	tbx[1].suffix = suf2
	
	tab_next()
}
