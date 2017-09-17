/// temp_animate_scenery(root)
/// @arg root

var root = argument0;

for (var i = 0; i < ds_list_size(scenery.scenery_tl_list); i++)
	with (scenery.scenery_tl_list[|i])
		with (block_animate(other.id, other.scenery.scenery_size))
			tl_set_parent(root)
		
scenery_animate = false
scenery_animate_root = null