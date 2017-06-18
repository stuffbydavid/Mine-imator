/// tl_save()
/// @desc Queues self and all children for saving.

save = true

if (temp)
{
    temp.save = true
    if (temp.type = "particles")
	{
        with (obj_particle_type)
		{
            if (creator != other.temp)
                continue
				
            if (temp)
                temp.save = true
				
            sprite_tex.save = true
        }
    }
}

for (var k = 0; k < keyframe_amount; k++)
    tl_keyframe_save(keyframe[k])

for (var t = 0; t < tree_amount; t++)
    with (tree[t])
        tl_save()
