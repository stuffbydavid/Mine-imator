/// tab_template_editor_particles_preview()

var size, xx, yy;
size = 128
tab_control(size)

xx = floor(dx + dw / 2 - size / 2)
yy = floor(dy)

if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
{
	tab_next()
	return 0
}

draw_box(xx, yy, size, size, false, c_background_secondary, 1)

var res, tex, swid, fwid, fhei, ani, frame, framesx, scale;

if (ptype_edit.temp = particle_sheet)
{
	res = ptype_edit.sprite_tex
	if (!res.ready)
		res = mc_res
	tex = res.particles_texture[ptype_edit.sprite_tex_image]
	swid = texture_width(tex)
	fwid = min(swid, ptype_edit.sprite_frame_width)
	fhei = ptype_edit.sprite_frame_height
	ani = particle_get_animation_percent(particle_editor_preview_start, ptype_edit.sprite_frame_start, ptype_edit.sprite_frame_end, particle_editor_preview_speed, ptype_edit.sprite_animation_onend)
	frame = round(ptype_edit.sprite_frame_start + (ptype_edit.sprite_frame_end - ptype_edit.sprite_frame_start) * ani)
	framesx = swid div fwid

	scale = min(size / fwid, size / fhei)

	draw_texture_start()
	draw_texture_part(tex, xx, yy, (frame mod framesx) * fwid, (frame div framesx) * fhei, fwid, fhei, scale, scale)
	draw_texture_done()
}
else
{
	var template = particle_template_map[?ptype_edit.sprite_template];
	
	var startf, endf;
	startf = (ptype_edit.sprite_template_reverse ? (template.frames - 1) : 0)
	endf = (ptype_edit.sprite_template_reverse ? 0 : (template.frames - 1))
	
	ani = particle_get_animation_percent(particle_editor_preview_start, startf, endf, particle_editor_preview_speed, ptype_edit.sprite_animation_onend)
	ani *= !ptype_edit.sprite_template_still_frame
	
	frame = round(startf + (endf - startf) * ani)
	
	var res = ptype_edit.sprite_template_tex;
	if (!res.ready)
		res = mc_res
	
	var texname = template.texture_list[|frame];
	
	tex = res.particle_texture_map[?texname]
	
	scale = min(size / texture_width(tex), size / texture_height(tex))
	
	draw_texture_start()
	draw_texture_part(tex, xx, yy, 0, 0, texture_width(tex), texture_height(tex), scale, scale)
	draw_texture_done()
}

draw_box(xx, yy + size - 4, size * ani, 4, false, c_accent, 1)

if (ptype_edit.temp = particle_sheet || (ptype_edit.temp = particle_template && !ptype_edit.sprite_template_still_frame))
{
	if (draw_button_icon("particlesresetpreview", xx + size + 4, yy + size - 28, 28, 28, false, icons.RESET, null, false, "tooltipparticlesresetpreview"))
		tab_template_editor_particles_preview_restart()
}

tab_next()
