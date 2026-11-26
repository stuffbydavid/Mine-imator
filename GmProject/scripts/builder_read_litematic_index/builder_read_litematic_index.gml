/// @desc Read a packed palette index without converting a 64-bit word to a real.

function builder_read_litematic_index(offset, bits, index)
{
	var bitpos, remaining, value, shift;
	bitpos = index * bits
	remaining = bits
	value = 0
	shift = 0

	while (remaining > 0)
	{
		var bytepos, bitoffset, count, byte;
		
		// NBT longs are big-endian, with palette bits starting at the low end
		bytepos = offset + (bitpos div 64) * 8 + 7 - ((bitpos mod 64) div 8)
		bitoffset = bitpos mod 8
		count = min(remaining, 8 - bitoffset)
		byte = buffer_peek(buffer_current, bytepos, buffer_u8)

		value += ((byte >> bitoffset) & ((1 << count) - 1)) << shift
		bitpos += count
		remaining -= count
		shift += count
	}

	return value
}
