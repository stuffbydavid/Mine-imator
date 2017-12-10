/// block_get_state_id(block, vars)
/// @arg block
/// @arg vars
/// @desc Gets a state ID (real number) from the variables, that is used for comparison by the builder.

var block, vars, varslen;
block = argument0
vars = argument1

varslen = array_length_1d(vars)
if (varslen = 0 || block.states_map = null)
	return 0
	
var sid = 0;

for (var i = 0; i < varslen; i += 2)
{
	var statename, valname, state, valid;
	statename = vars[@ i]
	valname = vars[@ i + 1]
	
	if (statename = "id")
		continue
	
	state = block.states_map[?statename]
	if (is_undefined(state))
	{
		log("Undefined state", block.name, statename)
		continue
	}
	
	valid = state.value_map[?valname]
	if (is_undefined(valid))
	{
		log("Undefined value", block.name, valname)
		continue
	}
	
	sid += state.value_id * valid;
}

return sid