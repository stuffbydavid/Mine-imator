/// tl_save()
/// @desc Queues self and all children for saving.

if (save)
	return 0

save = true

// Save associated templates
if (temp)
{
	temp.save = true
	
	if (temp.type = e_temp_type.PARTICLE_SPAWNER)
	{
		with (obj_particle_type)
		{
			if (creator != other.temp)
				continue
				
			if (temp)
				temp.save = true
				
			sprite_tex.save = true
			sprite_template_tex.save = true
		}
	}
}
	
// Save keyframes
for (var k = 0; k < ds_list_size(keyframe_list); k++)
	tl_keyframe_save(keyframe_list[|k])

// Save tree structure
for (var t = 0; t < ds_list_size(tree_list); t++)
	with (tree_list[|t])
		tl_save()
