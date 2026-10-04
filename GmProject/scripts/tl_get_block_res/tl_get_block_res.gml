/// @desc Returns the block mesh resource for a timeline or its particles

function tl_get_block_res()
{
	switch (type)
	{
		case e_tl_type.BLOCK:
			return temp
		
		case e_tl_type.SCENERY:
			return temp.scenery
		
		case e_tl_type.MODEL:
		{
			if (temp.model != null && temp.model.model_format = e_model_format.BLOCK)
				return temp.model
			
			break
		}
		
		case e_tl_type.PARTICLE_SPAWNER:
		{
			if (render_particles && ds_list_valid(particle_list) && ds_list_size(particle_list) > 0 && ds_list_valid(temp.pc_type_list))
			{
				for (var p = 0; p < ds_list_size(temp.pc_type_list); p++)
				{
					var ptype, ptemp, res;
					ptype = temp.pc_type_list[|p]
					ptemp = ptype.temp
					res = null
					
					if (ptemp = particle_sheet || ptemp = particle_template)
						continue

					if (ptemp.type = e_temp_type.BLOCK)
						res = ptemp
					else if (ptemp.type = e_temp_type.SCENERY)
						res = ptemp.scenery
					else if (ptemp.type = e_temp_type.MODEL && ptemp.model != null && ptemp.model.model_format = e_model_format.BLOCK)
						res = ptemp.model

					if (res != null && res.block_vbuffer != null && res.block_vbuffer_active != null &&
						(res.block_vbuffer_active[e_block_depth.DEPTH1] || res.block_vbuffer_active[e_block_depth.DEPTH2]))
						return res
				}
			}
			
			break
		}
	}
	
	return null
}
