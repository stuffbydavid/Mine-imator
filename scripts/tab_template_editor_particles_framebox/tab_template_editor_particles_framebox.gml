/// tab_template_editor_particles_framebox()

var size, xx, yy, res, tex, swid, scale;
var fwid, fhei, framesx, mouseframe;
size = 256
tab_control(size + 40)

xx = floor(dx + dw / 2 - size / 2)
yy = floor(dy + 20)

if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
{
	tab_next()
	return 0
}

res = ptype_edit.sprite_tex
if (!res.ready)
	res = mc_res
tex = res.particles_texture[ptype_edit.sprite_tex_image]
swid = texture_width(tex)

scale = min(size / swid, size / texture_height(tex))

fwid = min(size, ptype_edit.sprite_frame_width * scale)
fhei = min(size, ptype_edit.sprite_frame_height * scale)
framesx = max(1, floor(swid / ptype_edit.sprite_frame_width))
mouseframe = floor((clamp(mouse_x - xx, 0, size - 1)) / fwid) + floor((clamp(mouse_y - yy, 0, size - 1)) / fhei) * framesx

draw_box(xx, yy, size, size, false, c_background_secondary, 1)
draw_texture(tex, xx, yy, scale, scale)

// Click and drag to select frames
if (app_mouse_box(xx, yy, size, size) && content_mouseon)
{
	mouse_cursor = cr_handpoint
	if (mouse_left_pressed)
	{
		window_busy = "particleeditortypeanimationstartend"
		action_lib_pc_type_sprite_frame_start(mouseframe, false)
		action_lib_pc_type_sprite_frame_end(mouseframe, false)
	}
}

if (window_busy = "particleeditortypeanimationstartend")
{
	mouse_cursor = cr_handpoint
	action_lib_pc_type_sprite_frame_end(mouseframe, false)
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Frames
for (var f = min(ptype_edit.sprite_frame_start, ptype_edit.sprite_frame_end); f <= max(ptype_edit.sprite_frame_start, ptype_edit.sprite_frame_end); f++)
{
	var bx, by, bh, col, alpha;
	bx = xx + (f mod framesx) * fwid
	by = yy + (f div framesx) * fhei
	if (by >= yy + size)
		break
	
	col = c_border
	alpha = a_border
	
	var reverse = (ptype_edit.sprite_frame_start < ptype_edit.sprite_frame_end);
	
	if (f = ptype_edit.sprite_frame_start)
	{
		col = c_accent
		alpha = 1
		
		draw_label(text_get("particleeditortypespriteframeboxstart"), bx + floor(fwid / 2), min(by + (reverse ? 0 : fhei), yy + size), fa_center, reverse ? fa_bottom : fa_top, col, 1, font_emphasis)
	}
	else if (f = ptype_edit.sprite_frame_end)
	{
		col = c_error
		alpha = 1
		
		draw_label(text_get("particleeditortypespriteframeboxend"), bx + floor(fwid / 2), min(by + (!reverse ? 0 : fhei), yy + size), fa_center, !reverse ? fa_bottom : fa_top, col, 1, font_emphasis)
	}
	
	if (by + fhei > yy + size)
		bh = yy + size - by
	else
		bh = fhei
	
	draw_outline(bx, by, fwid, bh, 1, col, alpha, true)
}
tab_next()
