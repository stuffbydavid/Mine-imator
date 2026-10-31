/// @desc Count source blocks and apply the resource filter to builder blocks.

function res_load_scenery_block_map(blocksonly = false)
{
	// Keep the decoded source before applying filters
	if (!block_meshes_load_blocks(blocksonly))
		return false

	if (blocksonly)
		return true

	var res, tlamount, blockcounts, meshesx, meshesy;
	res = id
	tlamount = 0
	blockcounts = array_create(array_length(block_objs), 0)
	meshesx = block_meshes_num[X]
	meshesy = block_meshes_num[Y]

	block_meshes_active = array_create(array_length(block_meshes), false)

	ds_map_clear(scenery_block_map)
	ds_map_clear(scenery_tl_types_count_map)
	
	mc_builder.block_tl_count_map = scenery_tl_types_count_map

	with (mc_builder)
	{
		var created = (ds_list_size(thread_list) = 0);
		if (created)
			builder_spawn_threads(1)

		with (thread_list[|0])
		{
			var water, keepwater;
			water = mc_assets.block_name_map[?"water"]
			keepwater = !block_get_filtered(res, water)

			for (var p = 0; p < build_size_total; p++)
			{
				builder_thread_set_pos(p)
				var block = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z]);
				if (block = null)
					continue

				blockcounts[@block.block_id]++

				if (block_get_filtered(res, block))
				{
					builder_set_block(build_pos[X], build_pos[Y], build_pos[Z], 0, 0, false)
					continue
				}

				var meshindex = block_mesh_get_index(build_pos[X], build_pos[Y], build_pos[Z], meshesx, meshesy);
				res.block_meshes_active[@meshindex] = true

				if (!keepwater && builder_get_waterlogged(build_pos[X], build_pos[Y], build_pos[Z]))
					builder_set_block(build_pos[X], build_pos[Y], build_pos[Z], block.block_id, builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z]), false)

				var counttl = block.timeline;
				
				// Sign counts are added when tile text is parsed
				if (counttl && block.tl_type = "sign")
					counttl = false
				
				// Upper door halves do not create timelines
				if (counttl && block.tl_type = "door")
					counttl = (block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z]), "half") != "upper")

				// Count double chests as one
				if (counttl && block.tl_type = "chest" && block.name != "ender_chest")
				{
					var state, facing;
					state = builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z])
					facing = block_get_state_id_value(block, state, "facing")

					if (builder_scenery_legacy || block_get_state_id_value(block, state, "type") != "single")
					{
						if (build_pos[X] + 1 < build_size[X] && builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]) = block)
							counttl = (block_get_state_id_value(block, builder_get_state_id(build_pos[X] + 1, build_pos[Y], build_pos[Z]), "facing") != facing)

						if (counttl && build_pos[Y] + 1 < build_size[Y] && builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]) = block)
							counttl = (block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y] + 1, build_pos[Z]), "facing") != facing)
					}
				}

				if (counttl)
				{
					var type = block.tl_type;
					res.scenery_tl_types_count_map[?type] = value_get_real(res.scenery_tl_types_count_map[?type], 0) + 1
					tlamount++
				}
			}
		}

		if (created)
			builder_combine_threads()

		sch_timeline_amount = tlamount
	}

	for (var i = 0; i < array_length(blockcounts); i++)
		if (blockcounts[i] > 0)
			scenery_block_map[?block_objs[i].name] = blockcounts[i]

	scenery_tl_types_count_ready = true

	return true
}
