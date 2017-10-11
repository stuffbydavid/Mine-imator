/// block_set_redstone_repeater()
/// @desc Set locked state.

var facingdir, facingdiropp, locked;
facingdir = string_to_dir(block_get_state_id_value(block_current, block_state_id_current, "facing"));
facingdiropp = dir_get_opposite(facingdir)
locked = "false"

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	if (d = facingdir || d = facingdiropp || build_edge[d])
		continue
		
	var otherblock = array3D_get(block_obj, build_size_z, point3D_add(build_pos, dir_get_vec3(d)));
	if (otherblock = null) // Skip air
		continue
	
	var otherstateid, otherfacingdir;
	otherstateid = array3D_get(block_state_id, build_size_z, point3D_add(build_pos, dir_get_vec3(d)))
	otherfacingdir = string_to_dir(block_get_state_id_value(block_current, otherstateid, "facing"))
	if (otherblock.name = "powered_repeater" && otherfacingdir = d)
	{
		locked = "true"
		break
	}
}

block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "locked", locked)

return 0