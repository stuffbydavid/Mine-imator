/// block_load_legacy_data_map(map, bitmask, bitbase)
/// @arg map
/// @arg bitmask
/// @arg base

var map, bitmask, bitbase, val;
map = argument0
bitmask = argument1
bitbase = argument2

val = ds_map_find_first(map)
while (!is_undefined(val))
{
	switch (val)
	{
		case "0x1":			block_load_legacy_data_map(map[?val], 1, 1);						break
		case "0x2":			block_load_legacy_data_map(map[?val], 2, 2);						break
		case "0x4":			block_load_legacy_data_map(map[?val], 4, 4);						break
		case "0x8":			block_load_legacy_data_map(map[?val], 8, 8);						break
		case "0x1+0x2":		block_load_legacy_data_map(map[?val], 3, 1);						break
		case "0x1+0x2+0x4":	block_load_legacy_data_map(map[?val], 7, 1);						break
		case "0x4+0x8":		block_load_legacy_data_map(map[?val], 12, 4);						break
		default:			block_load_legacy_data_state(val, map[?val], bitmask, bitbase);	break
	}
	
	val = ds_map_find_next(map, val)
}