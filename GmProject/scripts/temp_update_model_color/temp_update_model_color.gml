/// temp_update_model_color()

function temp_update_model_color()
{
	var useblendprev = model_use_blend_color;
	
	if (model_file != null && model_file.model_color != "none")
	{
		model_use_blend_color = true
		
		if (!useblendprev)
			model_blend_color = minecraft_get_color(model_file.model_color)
	}
	else
	{
		model_use_blend_color = false
		model_blend_color = c_white
	}
	
	model_blend_color_default = model_blend_color
}