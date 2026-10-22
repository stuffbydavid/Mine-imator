function builder_read_schematic_tile_entities()
{
	// Tile entities
	if (ds_list_valid(sch_tileentity_list))
	{
		builder_spawn_threads(1)
		
		with (thread_list[|0])
		{
			debug_timer_start()
			
			for (var i = 0; i < ds_list_size(other.sch_tileentity_list); i++)
			{
				var entity, data, poslist, eid, ex, ey, ez;
				entity = other.sch_tileentity_list[|i]
				if (!ds_map_valid(entity))
					continue
				
				data = entity
						
				if (!builder_scenery_legacy)
				{
					eid = entity[?"Id"]
					if (!is_string(eid))
						eid = entity[?"id"]
					
					poslist = entity[?"Pos"]
					
					if (entity[?"Pos_NBT_type"] != e_nbt.TAG_INT_ARRAY || entity[?"Pos_NBT_length"] != 3 ||
						!is_real(poslist) || poslist < 0 || poslist + 12 > buffer_get_size(buffer_current))
						continue
					
					buffer_seek(buffer_current, buffer_seek_start, poslist)
					ex = buffer_read_int_be()
					ez = buffer_read_int_be()
					ey = buffer_read_int_be()
					
					// Sponge v3 stores the block entity data separately
					if (entity[?"Data_NBT_type"] = e_nbt.TAG_COMPOUND && ds_map_valid(entity[?"Data"]))
						data = entity[?"Data"]
				}
				else
				{
					eid = entity[?"id"]
					ex = entity[?"x"]
					ey = entity[?"z"]
					ez = entity[?"y"]
				}
				
				if (!is_real(ex) || !is_real(ey) || !is_real(ez) ||
					ex < 0 || ey < 0 || ez < 0 || ex >= build_size[X] || ey >= build_size[Y] || ez >= build_size[Z])
					continue
				
				if (is_string(eid))
				{
					var scr = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""));
					if (scr > -1)
					{
						build_pos[X] = ex
						build_pos[Y] = ey
						build_pos[Z] = ez
						build_pos_index = build_pos[Z] * build_size_xy + build_pos[Y] * build_size[X] + build_pos[X]
						
						block_current = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z])
						if (block_current = null)
							continue
						
						block_state_id_current = builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z])
						script_execute(scr, data)
					}
				}
			}
			
			debug_timer_stop("Parse Tile Entities")
		}
		
		builder_combine_threads()
	}
}
