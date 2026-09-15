/// tl_animate_scenery()

function tl_animate_scenery()
{
	var list = temp.scenery.scenery_tl_list
	if ((temp.scenery.scenery_tl_add = null || temp.scenery.scenery_tl_add) && ds_list_valid(list))
	{
		part_list = ds_list_create()
		
		for (var i = 0; i < ds_list_size(list); i++)
			with (list[|i])
				block_animate(other.id)
	}
	
	scenery_animate = false
}
