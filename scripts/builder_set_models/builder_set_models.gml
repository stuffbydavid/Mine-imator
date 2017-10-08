/// builder_set_models()

block_current = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z);
if (block_current != null) // Skip air/unknown blocks
{
	block_state_id_current = array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z);
	
	// Has timeline
	if (block_current.timeline && block_tl_list != null)
	{
		//block_pos = point3D_mul(build_pos, block_size)
		//ds_list_add(block_tl_list, block_get_timeline(block_current, block_state_id_current))
	}
	else
	{
		// Check edges
		/*build_edge[e_dir.EAST]	= (build_pos_x = build_size_x - 1)
		build_edge[e_dir.WEST]	= (build_pos_x = 0)
		build_edge[e_dir.SOUTH] = (build_pos_y = build_size_y - 1)
		build_edge[e_dir.NORTH] = (build_pos_y = 0)
		build_edge[e_dir.UP]	= (build_pos_z = build_size_z - 1)
		build_edge[e_dir.DOWN]	= (build_pos_z = 0)*/

		if (block_current.state_id_variant != null)
		{
			var variant = block_current.state_id_variant[block_state_id_current];
			if (!is_undefined(variant) && variant != null && variant.model_amount > 0)
			{
				var rendermodel = null;
				if (variant.model_amount > 1)
				{
					// Pick a random model from the list
					var rand = irandom(variant.total_weight - 1);
					for (var m = 0; m < variant.model_amount; m++)
					{
						rand -= variant.model[m].weight
						if (rand <= 0)
						{
							rendermodel = variant.model[m]
							break
						}
					}
				}
				else
					rendermodel = variant.model[0]
			
				array3D_set(block_render_model, build_size_z, build_pos_x, build_pos_y, build_pos_z, rendermodel)
			}
		}
	}
}