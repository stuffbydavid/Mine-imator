/// tl_animate_scenery()

if (temp.scenery.scenery_tl_add)
{
	part_list = ds_list_create()

	for (var i = 0; i < ds_list_size(temp.scenery.scenery_tl_list); i++)
		with (temp.scenery.scenery_tl_list[|i])
			block_animate(other.id)
}

scenery_animate = false