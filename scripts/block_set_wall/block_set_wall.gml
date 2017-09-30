/// block_set_wall()

var east, west, south, north;
east = state_vars_get_value(vars, "east")
west = state_vars_get_value(vars, "west")
south = state_vars_get_value(vars, "south")
north = state_vars_get_value(vars, "north")
block_set_fence()

if ((east && west && !south && !north) || (!east && !west && south && north))
	state_vars_set_value(vars, "up", "false")
else
	state_vars_set_value(vars, "up", "true")

return 0