/// minecraft_assets_load_legacy_block_data(id, map, bitmask, bitbase)
/// @arg id
/// @arg map
/// @arg bitmask
/// @arg base

var curid, map, bitmask, bitbase, key;
curid = argument0
map = argument1
bitmask = argument2
bitbase = argument3

key = ds_map_find_first(map)
while (!is_undefined(key))
{
	switch (key)
	{
		// Bitmask
		case "0x1":			minecraft_assets_load_legacy_block_data(curid, map[?key], 1, 1); break
		case "0x2":			minecraft_assets_load_legacy_block_data(curid, map[?key], 2, 2); break
		case "0x4":			minecraft_assets_load_legacy_block_data(curid, map[?key], 4, 4); break
		case "0x8":			minecraft_assets_load_legacy_block_data(curid, map[?key], 8, 8); break
		case "0x1+0x2":		minecraft_assets_load_legacy_block_data(curid, map[?key], 3, 1); break
		case "0x1+0x2+0x4":	minecraft_assets_load_legacy_block_data(curid, map[?key], 7, 1); break
		case "0x4+0x8":		minecraft_assets_load_legacy_block_data(curid, map[?key], 12, 4); break
		
		// Number (apply previous bitmask)
		default:
		{
			var val, statevars, newid, block;
			val = string_get_real(key)
			statevars = string_get_state_vars(map[?key])
			newid = state_vars_get_value(statevars, "id");
			block = null
			if (is_string(newid) && !is_undefined(block_id_map[?newid]))
				block = block_id_map[?newid]
			
			// Insert into array
			if (bitmask > 0)
			{
				for (var d = 0; d < 16; d++)
				{
					if ((d & bitmask) / bitbase = val) // Check data value with bitmask
					{
						// ID
						if (block != null)
							legacy_block_obj[curid, d] = block
						
						// State
						if (legacy_block_state_vars[curid, d] = null)
							legacy_block_state_vars[curid, d] = array()
						state_vars_add(legacy_block_state_vars[curid, d], statevars)
					}
				}
			}
			else
			{
				// ID
				if (block != null)
					legacy_block_obj[curid, val] = block
				
				// State
				if (legacy_block_state_vars[curid, val] = null)
					legacy_block_state_vars[curid, val] = array()
				state_vars_add(legacy_block_state_vars[curid, val], statevars)
			}
			
			break	
		}
	}
	
	key = ds_map_find_next(map, key)
}