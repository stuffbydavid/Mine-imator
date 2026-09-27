/// CppSeparate void builder_read_blocks_file(Scope<obj_builder>)
/// Reads a legacy .blocks file

function builder_read_blocks_file()
{
	debug_timer_start()
	
	file_map = buffer_read_string_short_be()
	build_size_y = buffer_read_short_be() // Derp
	build_size_x = buffer_read_short_be()
	build_size_z = buffer_read_short_be()
	log("Size", string(build_size_x) + " x " + string(build_size_y) + " x " + string(build_size_z))
	
	builder_start()
	sch_timeline_amount = 0
	
	repeat (build_size_total)
	{
		var blockid, stateid, bid, bdata;
		blockid = 0
		stateid = null
							
		// Read legacy block ID & data
		bid = buffer_read(buffer_current, buffer_u8)
		bdata = buffer_read(buffer_current, buffer_u8) mod 16
		if (bid > 0)
		{
			var block = legacy_block_obj[bid, bdata];
			stateid = legacy_block_state_id[bid, bdata]
			if (block != null)
			{
				blockid = block.block_id
				if (block.timeline)
					sch_timeline_amount++
			}
		}
							
		buffer_write(block_obj, buffer_u16, blockid)
		buffer_write(block_state_id, buffer_u16, stateid)
	}
	
	debug_timer_stop("Loaded .blocks")
}
