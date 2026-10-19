function tl_animate_scenery()
{
	var list = temp.scenery.scenery_tl_list;
	if (ds_list_valid(list) && (temp.scenery.scenery_tl_all_types || array_length(temp.scenery.scenery_tl_types) > 0))
	{
		part_list = ds_list_create()
		
		for (var i = 0; i < ds_list_size(list); i++)
			with (list[|i])
				block_animate(other.id)
	}

	if (placed)
		tl_mark_placed(true)
	
	scenery_animate = false
}
