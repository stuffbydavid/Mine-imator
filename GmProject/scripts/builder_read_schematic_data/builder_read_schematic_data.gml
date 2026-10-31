/// CppSeparate BoolType builder_read_schematic_data(Scope<obj_builder>, IntType, IntType, IntType, IntType)
/// @desc Decode and validate palette indices before mesh generation.

function builder_read_schematic_data(version, map, paletteindices, blockamount)
{
	var key, readpos, length, datatype, sourcesize, rawbytes, endpos, writepos;
	key = (version >= 3 ? "Data" : "BlockData");
	readpos = map[?key]
	length = map[?key + "_NBT_length"]
	datatype = map[?key + "_NBT_type"]
	sourcesize = buffer_get_size(buffer_current)
	
	if (!is_real(readpos) || !is_real(length) || (datatype != e_nbt.TAG_BYTE_ARRAY && datatype != e_nbt.TAG_INT_ARRAY))
	{
		log("Schematic error", "Block data array not found or has invalid type")
		return false
	}
	
	endpos = readpos + length * (datatype = e_nbt.TAG_INT_ARRAY ? 4 : 1)
	if (readpos < 0 || length < blockamount || endpos > sourcesize)
	{
		log("Schematic error", "Block data array is truncated")
		return false
	}
	
	// Some v1 files store one raw byte per block
	rawbytes = (version = 1 && datatype = e_nbt.TAG_BYTE_ARRAY && length = blockamount)

	// Compact palettes fit in one byte regardless of their original IDs
	sch_blockdata_ints = (ds_map_size(paletteindices) > 256)
	sch_blockdata_array = sourcesize
	writepos = sourcesize
	
	buffer_resize(buffer_current, sourcesize + blockamount * (sch_blockdata_ints ? 4 : 1))
	
	for (var i = 0; i < blockamount; i++)
	{
		var value = 0;
		if (datatype = e_nbt.TAG_INT_ARRAY)
		{
			for (var b = 0; b < 4; b++)
				value = value * 256 + buffer_peek(buffer_current, readpos + b, buffer_u8)
			
			readpos += 4
		}
		else if (rawbytes)
		{
			value = buffer_peek(buffer_current, readpos, buffer_u8)
			readpos++
		}
		else
		{
			var mul, bytes, byte;
			mul = 1
			bytes = 0
			
			do
			{
				if (readpos >= endpos || bytes = 5)
				{
					log("Schematic error", "Truncated or oversized block varint")
					return false
				}
				
				byte = buffer_peek(buffer_current, readpos, buffer_u8)
				readpos++
				bytes++
				
				if (bytes = 5 && byte > 7)
				{
					log("Schematic error", "Block varint exceeds a non-negative integer")
					return false
				}
				
				value += (byte mod 128) * mul
				mul *= 128
			}
			until (byte < 128)
		}

		value = paletteindices[?value]
		if (is_undefined(value))
		{
			log("Schematic error", "Block data references a missing palette entry")
			return false
		}
		
		if (sch_blockdata_ints)
		{
			buffer_poke(buffer_current, writepos, buffer_u8, (value div 16777216) mod 256)
			buffer_poke(buffer_current, writepos + 1, buffer_u8, (value div 65536) mod 256)
			buffer_poke(buffer_current, writepos + 2, buffer_u8, (value div 256) mod 256)
			buffer_poke(buffer_current, writepos + 3, buffer_u8, value mod 256)
			writepos += 4
		}
		else
		{
			buffer_poke(buffer_current, writepos, buffer_u8, value)
			writepos++
		}
	}
	
	if (readpos != endpos)
	{
		log("Schematic error", "Block data contains more entries than the schematic size")
		return false
	}
	
	return true
}
