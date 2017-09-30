/// block_load_legacy_data_state(value, state, bitmask, bitbase)
/// @arg value
/// @arg state
/// @arg bitmask

var value, state, bitmask, bitbase;
value = string_get_real(argument0)
state = string_split(argument1, "=");
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
		
		var arr, arrlen;
		arr = legacy_data_state[d]
		arrlen = array_length_1d(arr)
		
		arr[@ arrlen] = state[0]
		if (array_length_1d(state) > 1)
			arr[@ arrlen + 1] = state[1]
		else
			arr[@ arrlen + 1] = ""
	}
}
else
{
	var arr, arrlen;
	arr = legacy_data_state[value]
	arrlen = array_length_1d(arr)
		
	arr[@ arrlen] = state[0]
	if (array_length_1d(state) > 1)
		arr[@ arrlen + 1] = state[1]
	else
		arr[@ arrlen + 1] = ""
}