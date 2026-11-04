// @desc Update block transparency render flag for a timeline.

function tl_update_render_blocks_transparent()
{
	if (array_length(block_meshes) > 0)
	{
		render_blocks_transparent = block_meshes_transparent
		return 0
	}
	
	render_blocks_transparent = false

	var obj = null;
	switch (type)
	{
		case e_tl_type.BLOCK:
			obj = temp
			break

		case e_tl_type.SCENERY:
			if (temp != null)
				obj = temp.scenery
			break

		case e_tl_type.MODEL:
			if (temp.model != null && temp.model.model_format = e_model_format.BLOCK)
				obj = temp.model
			break

		case e_tl_type.PARTICLE_SPAWNER:
		{
			if (ds_list_valid(temp.pc_type_list))
			{
				for (var p = 0; p < ds_list_size(temp.pc_type_list); p++)
				{
					var ptype, ptemp;
					ptype = temp.pc_type_list[|p]
					ptemp = ptype.temp
					obj = null

					if (ptemp = particle_sheet || ptemp = particle_template)
						continue

					if (ptemp.type = e_temp_type.BLOCK)
						obj = ptemp
					else if (ptemp.type = e_temp_type.SCENERY)
						obj = ptemp.scenery
					else if (ptemp.type = e_temp_type.MODEL && ptemp.model != null && ptemp.model.model_format = e_model_format.BLOCK)
						obj = ptemp.model

					if (obj != null && obj.block_meshes_transparent)
						break
				}
			}
			break
		}
	}

	if (obj != null)
		render_blocks_transparent = obj.block_meshes_transparent
}
