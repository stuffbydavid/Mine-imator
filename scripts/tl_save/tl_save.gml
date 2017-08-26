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

for (var k = 0; k < ds_list_size(keyframe_list); k++)
	tl_keyframe_save(keyframe_list[|k])

for (var t = 0; t < ds_list_size(tree_list); t++)
	with (tree_list[|t])
		tl_save()
