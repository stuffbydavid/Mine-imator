/// CppSeparate BoolType block_mesh_load_blocks(Scope<obj_block_mesh>, VecType)
/// @desc Save decoded blocks into the block mesh in XYZ order, with X varying fastest.
/// Palette entries are little-endian u16 block ID + u16 state ID.
/// Grid indices use ceil(log2(palette size)) bits, least significant bit first, without padding.
/// A palette-indexed waterlogged bitset follows the packed grid, starting at the next byte.
/// A single-entry palette has no grid bits.

function block_mesh_load_blocks(start)
{
	// Clear previous block data
	if (block_palette_buffer != null)
		buffer_delete(block_palette_buffer)

	if (block_grid_buffer != null)
		buffer_delete(block_grid_buffer)

	// Keep temporary indices until the complete palette determines their bit width
	var sizetotal, indices, palette, entries, active;
	sizetotal = block_grid_size[X] * block_grid_size[Y] * block_grid_size[Z]
	indices = buffer_create(sizetotal * 4, buffer_fixed, 1)
	palette = ds_int_map_create()
	entries = []
	active = false

	// Collect unique block states in the same XYZ order as the grid
	for (var zz = 0; zz < block_grid_size[Z]; zz++)
	for (var yy = 0; yy < block_grid_size[Y]; yy++)
	for (var xx = 0; xx < block_grid_size[X]; xx++)
	{
		var pos, blockid, stateid, waterlogged, key, index;
		pos = (start[Z] + zz) * mc_builder.build_size_xy + (start[Y] + yy) * mc_builder.build_size[X] + start[X] + xx
		blockid = buffer_peek(mc_builder.block_obj, pos * 2, buffer_u16)
		stateid = buffer_peek(mc_builder.block_state_id, pos * 2, buffer_u16)
		waterlogged = buffer_peek(mc_builder.block_waterlogged, pos, buffer_u8)
		
		// Ignore unused state values on air blocks
		if (blockid = 0)
			stateid = 0

		// Waterlogged and dry blocks need separate palette entries
		key = blockid + stateid * 65536 + waterlogged * 4294967296
		index = palette[?key]
		if (is_undefined(index))
		{
			index = array_length(entries)
			palette[?key] = index
			entries[@index] = key
		}

		buffer_write(indices, buffer_u32, index)
		active = (active || blockid != 0 || waterlogged)
	}

	// Use the minimum number of bits needed to address the palette
	var count, bits, gridbytes;
	count = array_length(entries)
	bits = 0
	while (power(2, bits) < count)
		bits++

	// Reserve whole bytes for the grid followed by one waterlogged bit per entry
	gridbytes = ceil(sizetotal * bits / 8)
	block_palette_buffer = buffer_create(count * 4, buffer_fixed, 1)
	block_grid_buffer = buffer_create(gridbytes + ceil(count / 8), buffer_fixed, 1)
	buffer_fill(block_grid_buffer, 0, buffer_u8, 0, buffer_get_size(block_grid_buffer))

	// Write each block/state pair as four little-endian bytes
	for (var i = 0; i < count; i++)
	{
		var entry = entries[i];
		buffer_write(block_palette_buffer, buffer_u16, entry & 65535)
		buffer_write(block_palette_buffer, buffer_u16, (entry >> 16) & 65535)

		// Store the waterlogged flag separately from the four-byte palette entry
		if ((entry >> 32) != 0)
		{
			var offset = gridbytes + (i div 8);
			buffer_poke(block_grid_buffer, offset, buffer_u8, buffer_peek(block_grid_buffer, offset, buffer_u8) | (1 << (i mod 8)))
		}
	}

	// Pack indices consecutively, including those that cross byte boundaries
	for (var p = 0; p < sizetotal && bits > 0; p++)
	{
		var value, bitpos, remaining;
		value = buffer_peek(indices, p * 4, buffer_u32)
		bitpos = p * bits
		remaining = bits

		// Fill the available bits in each byte before advancing
		while (remaining > 0)
		{
			var offset, shift, take;
			offset = bitpos div 8
			shift = bitpos mod 8
			take = min(remaining, 8 - shift)
			buffer_poke(block_grid_buffer, offset, buffer_u8, buffer_peek(block_grid_buffer, offset, buffer_u8) | ((value & ((1 << take) - 1)) << shift))
			value = value >> take
			bitpos += take
			remaining -= take
		}
	}

	// Only the compact palette and grid remain owned by the mesh
	ds_map_destroy(palette)
	buffer_delete(indices)

	return active
}
