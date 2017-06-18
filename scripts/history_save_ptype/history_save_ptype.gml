/// history_save_ptype(ptype)
/// @arg ptype
/// @desc Saves a particle type in memory.

var ptype, save;
ptype = argument0
save = new(obj_history_save)
save.hobj = id

with (ptype)
    ptype_copy(save)

with (save)
{
    iid = ptype.iid
    creator = iid_get(creator)
    temp = iid_get(temp)
    sprite_tex = iid_get(sprite_tex)
}

return save
