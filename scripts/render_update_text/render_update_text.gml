/// render_update_text()
/// @desc Updates the text of affected objects

with (obj_timeline)
{
	if (type != "text")
		continue
		
	var text, font;
	text = value[e_value.TEXT]
	font = value[e_value.TEXT_FONT]
	if (text = "")
		text = id.text
	if (font = null)
		font = temp.text_font
		
	render_generate_text(text, font, temp.text_3d)
}
		
with (obj_particle_type)
	if (temp != null && temp.type = "text")
		render_generate_text(id.text, temp.text_font, temp.text_3d)
		
with (obj_preview)
	if (instance_exists(select) && select.type = "text")
		render_generate_text("AaBbCc", select.text_font, select.text_3d)