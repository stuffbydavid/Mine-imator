/// minecraft_assets_load_legacy_block_data(id, map, bitmask, bitbase)
/// @arg id
/// @arg map
/// @arg bitmask
/// @arg base

function minecraft_assets_load_legacy_block_data(curid, map, bitmask, bitbase)
{
	var key = ds_map_find_first(map);
	
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
				var val, statevars, newid, newidnomc, block;
				val = string_get_real(key)
				statevars = string_get_state_vars(map[?key])
				newid = state_vars_get_value(statevars, "id")
				if (newid != null)
					newidnomc = string_replace(newid, "minecraft:", "")
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
							// State
							if (legacy_block_state_vars[curid, d] = null)
								legacy_block_state_vars[curid, d] = array()
							
							// ID
							if (block != null)
							{
								legacy_block_obj[curid, d] = block
								if (block.id_state_vars_map != null && !is_undefined(block.id_state_vars_map[?newid]))
									state_vars_add(legacy_block_state_vars[curid, d], block.id_state_vars_map[?newid]) // Add ID-specific vars
							}
							
							// Overwrite by data specific vars
							state_vars_add(legacy_block_state_vars[curid, d], statevars)
							
							// World importer
							if (newid != null)
								legacy_block_mc_id[curid, d] = newidnomc
						}
					}
				}
				else
				{
					// State
					if (legacy_block_state_vars[curid, val] = null)
						legacy_block_state_vars[curid, val] = array()
					
					// ID
					if (block != null)
					{
						legacy_block_obj[curid, val] = block
						if (block.id_state_vars_map != null && !is_undefined(block.id_state_vars_map[?newid]))
							state_vars_add(legacy_block_state_vars[curid, val], block.id_state_vars_map[?newid]) // Add ID-specific vars
					}
					
					// Overwrite by data specific vars
					state_vars_add(legacy_block_state_vars[curid, val], statevars)
					
					// World importer
					if (newid != null)
						legacy_block_mc_id[curid, val] = newidnomc
				}
				
				break	
			}
		}
		
		key = ds_map_find_next(map, key)
	}
}
