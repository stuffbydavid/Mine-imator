/// render_update_text()
/// @desc Updates the text of affected objects

function render_update_text()
{
	with (obj_timeline)
	{
		if (type != e_tl_type.TEXT)
			continue
		
		var text, font;
		text = value[e_value.TEXT]
		font = value[e_value.TEXT_FONT]
		if (text = "")
			text = id.text
		if (font = null)
			font = temp.text_font
		
		render_generate_text(text, font, temp.text_3d, value[e_value.TEXT_HALIGN], value[e_value.TEXT_VALIGN], value[e_value.TEXT_AA])
	}
	
	with (obj_particle_type)
		if ((temp != particle_sheet && temp != particle_template) && temp != null && temp.type = e_temp_type.TEXT)
			render_generate_text(id.text, temp.text_font, temp.text_3d)
	
	with (obj_preview)
		if (instance_exists(select) && select.object_index != obj_resource && select.type = e_temp_type.TEXT)
			render_generate_text("AaBbCc", select.text_font, select.text_3d)
}
