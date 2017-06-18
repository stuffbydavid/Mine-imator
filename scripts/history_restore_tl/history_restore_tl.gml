/// history_restore_tl(save)
/// @arg save
/// @desc Restores a saved timeline.

var save, tl;
save = argument0
tl = new(obj_timeline)

with (save)
    tl_copy(tl)
    
with (tl)
{
    iid = save.iid
    temp = iid_find(temp)
    if (temp && !part_of)
        temp.count++
    
    for (var v = 0; v < values; v++)
        value_default[v] = save.value_default[v]
	
    for (var k = 0; k < keyframe_amount; k++)
	{
        keyframe[k] = new(obj_keyframe)
        with (keyframe[k])
		{
            pos = save.kf_pos[k]
            id.tl = tl
            index = k
            select = false
            sound_play_index = null
            for (var v = 0; v < values; v++)
                value[v] = tl_value_restore(v, null, save.kf_value[k, v])
        }
    }
    
    parent = iid_find(parent)
    tl_parent_add()
    
    part_of = iid_find(part_of)
    if (part_of)
        part_of.part[bodypart] = id
        
    // Restore recursively
    tree_amount = 0
    for (var t = 0; t < save.tree_amount; t++)
        history_restore_tl(save.tree[t])
        
    // Restore references
    for (var s = 0; s < save.usage_temp_shape_tex_amount; s++)
        with (iid_find(save.usage_temp_shape_tex[s]))
            shape_tex = tl
        
    for (var s = 0; s < save.usage_tl_texture_amount; s++)
	{
        with (iid_find(save.usage_tl_texture[s]))
		{
            value[TEXTUREOBJ] = tl
            update_matrix = true
        }
    }
            
    for (var s = 0; s < save.usage_tl_attractor_amount; s++)
	{
        with (iid_find(save.usage_tl_attractor[s]))
		{
            value[ATTRACTOR] = tl
            update_matrix = true
        }
    }
            
    for (var s = 0; s < save.usage_kf_texture_amount; s++)
        with (iid_find(save.usage_kf_texture_tl[s]))
            keyframe[save.usage_kf_texture_index[s]].value[TEXTUREOBJ] = tl
            
    for (var s = 0; s < save.usage_kf_attractor_amount; s++)
        with (iid_find(save.usage_kf_attractor_tl[s]))
            keyframe[save.usage_kf_attractor_index[s]].value[ATTRACTOR] = tl

    // Update
    tl_update_type_name()
    tl_update_display_name()
    tl_update_rot_point()
    tl_update_value_types()
    tl_update_values()
    tl_update_depth()
    if (type = "particles")
        particle_spawner_init()
}

return tl
