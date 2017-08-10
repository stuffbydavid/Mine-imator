/// block_load_legacy_data_state(value, state, bitmask, bitbase)
/// @arg value
/// @arg state
/// @arg bitmask

var value, state, bitmask, bitbase;
value = string_get_real(argument0)
state = argument1
bitmask = argument2
bitbase = argument3
	
// Insert into array
if (bitmask > 0)
{
	for (var d = 0; d < 16; d++)
	{
		// Check data value with bit mask, skip if not matched
		if ((d & bitmask) / bitbase != value)
			continue
		
		if (legacy_data_state_map[d] = null)
			legacy_data_state_map[d] = ds_map_create()
			
		block_vars_string_to_map(state, legacy_data_state_map[d])
	}
}
else
{
	if (legacy_data_state_map[value] = null)
		legacy_data_state_map[value] = ds_map_create()
		
	block_vars_string_to_map(state, legacy_data_state_map[value])
}