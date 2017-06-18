/// render_update_text()
/// @desc Updates the text of affected objects

with (obj_timeline)
	if (type = "text")
		render_generate_text(text, temp.text_font)
		
with (obj_particle_type)
	if (temp && temp.type = "text")
		render_generate_text(text, temp.text_font)
		
with (obj_preview)
	if (instance_exists(select) && select.type = "text")
		render_generate_text("AaBbCc", select.text_font)