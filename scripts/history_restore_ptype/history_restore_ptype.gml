/// history_restore_ptype(save, creator)
/// @arg save
/// @arg creator
/// @desc Adds a saved particle type.

var save, ptype;
save = argument0
ptype = new(obj_particle_type)

with (save)
    ptype_copy(ptype)
    
with (ptype)
{
    creator = argument1
    for (var t = creator.pc_types; t > creator_pos; t--) // Push up
	{
        creator.pc_type[t] = creator.pc_type[t - 1]
        creator.pc_type[t].creator_pos++
    }
    creator.pc_type[creator_pos] = id
    creator.pc_types++
    
    iid = save.iid
    temp = iid_find(temp)
    sprite_tex = iid_find(sprite_tex)
    sprite_tex.count++
    ptype_update_sprite_vbuffers()
}

return ptype
