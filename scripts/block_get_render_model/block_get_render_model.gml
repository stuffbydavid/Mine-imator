/// block_get_render_model(modelobject, brightness, offset, offsetxy)
/// @arg modelobject
/// @arg brightness
/// @arg offset
/// @arg offsetxy
/// @desc Returns a random or single model.

function block_get_render_model(modelobj, brightness, offset, offsetxy)
{
	instance_activate_object(modelobj)
	
	with (modelobj)
	{
		if (model_amount > 1 && app.project_render_random_blocks)
		{
			// Pick a random model from the list
			var rand = irandom(total_weight - 1) + 1;
			for (var m = 0; m < model_amount; m++)
			{
				rand -= model[m].weight
				if (rand <= 0)
				{
					model[m].brightness = brightness
					model[m].random_offset = offset
					model[m].random_offset_xy = offsetxy
					
					instance_deactivate_object(modelobj)
					return model[m]
				}
			}
		}
		else if (model_amount > 0 || app.project_render_random_blocks)
		{
			model[0].brightness = brightness
			model[0].random_offset = offset
			model[0].random_offset_xy = offsetxy
			
			instance_deactivate_object(modelobj)
			return model[0]
		}
		
		instance_deactivate_object(modelobj)
		return null
	}
}
