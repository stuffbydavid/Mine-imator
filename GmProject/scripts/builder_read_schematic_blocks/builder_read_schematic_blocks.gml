/// CppSeparate void builder_read_schematic_blocks(Scope<obj_builder>)
/// @desc Read the blocks in a .schematic file and generate 3 buffers for block object ids, block states and waterlogged flags.
/// On the C++ side, 16x16x16 sections are generated with the schematic palettes. These sections are pre-generated when importing from a world.

function builder_read_schematic_blocks()
{
	debug_timer_start()
	builder_start()
	sch_timeline_amount = 0
	
	for (var b = 0; b < build_size_total; b++)
	{
		var block, blockid, stateid, waterlogged;
		block = null
		blockid = 0
		stateid = null
		waterlogged = false
							
		if (!builder_scenery_legacy)
		{
			// Read index
			var bindex;
			if (sch_blockdata_ints)
			{
				// Read big endian int
				var off, b1, b2, b3, b4;
				off = sch_blockdata_array + b * 4
				b1 = buffer_peek(buffer_current, off, buffer_u8)
				b2 = buffer_peek(buffer_current, off + 1, buffer_u8)
				b3 = buffer_peek(buffer_current, off + 2, buffer_u8)
				b4 = buffer_peek(buffer_current, off + 3, buffer_u8)
				bindex = b1 * 16777216 + b2 * 65536 + b3 * 256 + b4
			}
			else
				bindex = buffer_peek(buffer_current, sch_blockdata_array + b, buffer_u8)
									
			if (bindex > 0)
			{
				block = sch_palette_blocks[bindex]
				stateid = sch_palette_stateids[bindex]
				waterlogged = sch_palette_waterlogged[bindex]
			}
		}
		else
		{
			// Read legacy block ID & data
			var bid = buffer_peek(buffer_current, sch_legacy_blocksarray + b, buffer_u8);
			if (bid > 0 && legacy_block_set[bid])
			{
				var bdata = buffer_peek(buffer_current, sch_legacy_dataarray + b, buffer_u8) mod 16;
				block = legacy_block_obj[bid, bdata]
				stateid = legacy_block_state_id[bid, bdata]
			}
		}
							
		if (block != null)
		{
			blockid = block.block_id
			if (block.timeline)
				sch_timeline_amount++
		}
							
		buffer_write(block_obj, buffer_u16, blockid)
		buffer_write(block_state_id, buffer_u16, stateid)
		buffer_write(block_waterlogged, buffer_u8, waterlogged)
	}
	
	debug_timer_stop("Parse blocks")
}
