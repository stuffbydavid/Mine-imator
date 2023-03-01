/// CppSeparate IntType block_get_render_model(VarType, RealType, BoolType, BoolType)
/// block_get_render_model(modelobject, emissive, offset, offsetxy)
/// @arg modelobject
/// @arg emissive
/// @arg offset
/// @arg offsetxy
/// @desc Returns a random or single model.

function block_get_render_model(modelobj, emissive, offset, offsetxy)
{
	instance_activate_object(modelobj)
	
	with (modelobj)
	{
		if (model_amount > 1 && mc_builder.build_randomize)
		{
			// Pick a random model from the list
			var rand = irandom(total_weight - 1) + 1;
			for (var m = 0; m < model_amount; m++)
			{
				rand -= model[m].weight
				if (rand <= 0)
				{
					model[m].emissive = emissive
					model[m].random_offset = offset
					model[m].random_offset_xy = offsetxy
					
					instance_deactivate_object(modelobj)
					return model[m].rendermodel_id
				}
			}
		}
		else if (model_amount > 0 || mc_builder.build_randomize)
		{
			model[0].emissive = emissive
			model[0].random_offset = offset
			model[0].random_offset_xy = offsetxy
			
			instance_deactivate_object(modelobj)
			return model[0].rendermodel_id
		}
		
		instance_deactivate_object(modelobj)
		return 0
	}
}
