/// render_update_text()
/// @desc Updates the text of affected objects

function render_update_text()
{
	with (obj_timeline)
	{
		if (type != e_tl_type.TEXT)
			continue
		
		var text, font, halign, valign, outlinesize;
		text = value[e_value.TEXT]
		font = has_temp ? value[e_value.TEXT_FONT] : null
		if (font = null)
			font = temp.text_font
		halign = has_temp && !value[e_value.TEXT_CUSTOM_ALIGNMENT] ? temp.text_halign : value[e_value.TEXT_HALIGN]
		valign = has_temp && !value[e_value.TEXT_CUSTOM_ALIGNMENT] ? temp.text_valign : value[e_value.TEXT_VALIGN]
		outlinesize = has_temp && !value[e_value.TEXT_CUSTOM_OUTLINE] ? temp.text_outline_size : value[e_value.TEXT_OUTLINE_SIZE]
		render_generate_text(text, font, temp.text_3d, halign, valign, temp.text_aa, outlinesize)
	}
	
	with (obj_particle_type)
		if ((temp != particle_sheet && temp != particle_template) && temp != null && temp.type = e_temp_type.TEXT)
			render_generate_text(id.text, temp.text_font, temp.text_3d, temp.text_halign, temp.text_valign, temp.text_aa, temp.text_outline_size)
	
	with (obj_preview)
	{
		if (instance_exists(select) && select.object_index != obj_resource && select.type = e_temp_type.TEXT)
		{
			var text = default_text;
			if (select.object_index = obj_bench_settings && select.text != "")
				text = select.text
			render_generate_text(text, select.text_font, select.text_3d, select.text_halign, select.text_valign, select.text_aa, select.text_outline_size)
		}
	}
}
