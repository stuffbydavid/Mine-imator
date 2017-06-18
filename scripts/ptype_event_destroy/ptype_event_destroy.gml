/// ptype_event_destroy()
/// @desc Destroy event of obj_particle_type.

// Remove from creator
creator.pc_types--
for (var i = creator_pos; i < creator.pc_types; i++) // Push down
{
    creator.pc_type[i] = creator.pc_type[i + 1]
    creator.pc_type[i].creator_pos--
}

if (temp_creator != app.bench_settings)
    sprite_tex.count--

for (var m = 0; m < sprite_vbuffers; m++)
    vbuffer_destroy(sprite_vbuffer[m])

// Destroy associated particles
with (obj_particle)
    if (type = other.id)
        instance_destroy()
        
ptype_edit = sortlist_remove(app.ptype_list, id)
