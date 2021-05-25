/// block_get_render_model(modelobject, brightness)
/// @arg modelobject
/// @arg brightness
/// @desc Returns a random or single model.

function block_get_render_model(modelobj, brightness)
{
	instance_activate_object(modelobj)
	
	with (modelobj)
	{
		if (model_amount > 1)
		{
			// Pick a random model from the list
			var rand = irandom(total_weight - 1) + 1;
			for (var m = 0; m < model_amount; m++)
			{
				rand -= model[m].weight
				if (rand <= 0)
				{
					model[m].brightness = brightness
					
					instance_deactivate_object(modelobj)
					return model[m]
				}
			}
		}
		else if (model_amount > 0)
		{
			model[0].brightness = brightness
			
			instance_deactivate_object(modelobj)
			return model[0]
		}
		
		instance_deactivate_object(modelobj)
		return null
	}
}
