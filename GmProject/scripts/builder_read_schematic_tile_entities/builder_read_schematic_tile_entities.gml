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
				var entity, eid, ex, ey, ez;
				entity = other.sch_tileentity_list[|i]
						
				if (!builder_scenery_legacy)
				{
					eid = entity[?"Id"]
					var poslist = entity[?"Pos"];
					buffer_seek(buffer_current, buffer_seek_start, poslist)
					ex = buffer_read_int_be()
					ez = buffer_read_int_be()
					ey = buffer_read_int_be()
				}
				else
				{
					eid = entity[?"id"]
					ex = entity[?"x"]
					ey = entity[?"z"]
					ez = entity[?"y"]
				}
				
				if (is_string(eid))
				{
					var script = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""));
					if (script > -1)
					{
						build_pos_x = ex
						build_pos_y = ey
						build_pos_z = ez
						build_pos = build_pos_z * build_size_xy + build_pos_y * build_size_x + build_pos_x;
						block_current = builder_get_block(build_pos_x, build_pos_y, build_pos_z)
						block_state_id_current = builder_get_state_id(build_pos_x, build_pos_y, build_pos_z)
						script_execute(script, entity)
					}
				}
			}
			debug_timer_stop("Parse Tile Entities")
		}
		builder_combine_threads()
	}
}
