/// block_load_legacy_data_state(value, state, bitmask, bitbase)
/// @arg value
/// @arg state
/// @arg bitmask

var value, state, bitmask, bitbase;
value = string_get_real(argument0)
state = string_get_state_vars(argument1)
bitmask = argument2
bitbase = argument3

// Insert into array
if (bitmask > 0)
{
	for (var d = 0; d < 16; d++)
		if ((d & bitmask) / bitbase = value) // Check data value with bit mask
			state_vars_add(legacy_data_state[d], state)
}
else
	state_vars_add(legacy_data_state[value], state)