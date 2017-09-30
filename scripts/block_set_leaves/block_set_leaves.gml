/// block_set_leaves()
/// @desc Returns the opaque or transparent model.

var variantval = state_vars_get_value(vars, "variant");

if (block_current.states_map != null)
{
	with (block_current.states_map[?"variant"])
	{
		for (var v = 0; v < value_amount; v++)
		{
			if (value_name[v] != variantval)
				continue
			
			with (value_file[v])
			{
				if (variant_amount = 0)
					break
		
				with (variant[0])
				{
					if (model_amount = 0)
						break
			
					if (app.background_opaque_leaves)
						return array(model_opaque[0])
					else
						return array(model[0])
				}
			}
			
			break
		}
	}
}

return null