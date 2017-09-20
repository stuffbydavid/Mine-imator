/// temp_animate_scenery(root)
/// @arg root

var root = argument0;
root.part_list = ds_list_create()

for (var i = 0; i < ds_list_size(scenery.scenery_tl_list); i++)
	with (scenery.scenery_tl_list[|i])
		block_animate(other.id, root)

scenery_animate = false
scenery_animate_root = null