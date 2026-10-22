/// @desc Resolve the resource filter to block IDs.

function res_load_scenery_filter_mask()
{
	scenery_filter_mask = array_create(array_length(block_objs), false)

	for (var i = 0; i < array_length(scenery_filter_array); i++)
	{
		var index = scenery_filter_array[i];
		if (index >= 0 && index < ds_list_size(mc_assets.block_list))
		{
			var block = mc_assets.block_list[|index];
			scenery_filter_mask[block.block_id] = true
		}
	}
}
