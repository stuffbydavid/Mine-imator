/// tl_update_bounding_box_trees()
/// @desc Merges bounding boxes in children to optimize frustum culling

function tl_update_bounding_box_trees()
{
	var levelarray, deepestlevel;
	levelarray = [null]
	deepestlevel = 0
	
	// Organize timelines into lists based on their 
	with (obj_timeline)
	{
		if (level > deepestlevel)
		{
			deepestlevel = level
			array_resize(levelarray, deepestlevel + 1)
		}
		
		levelarray[level] = array_add(levelarray[level], id)
	}
	
	// Merge bounding boxes
	for (var i = array_length(levelarray) - 1; i >= 0; i--)
	{
		for (var j = 0; j < array_length(levelarray[i]); j++)
		{
			var tl = levelarray[i][j];
			
			tl.bounding_box_children.copy(tl.bounding_box_matrix)
			tl.bounding_box_children_list = []	
			
			for (var k = 0; k < ds_list_size(tl.tree_list); k++)
			{
				var child = tl.tree_list[|k];
				tl.bounding_box_children.merge(child.bounding_box_children)
				
				// Add children list
				tl.bounding_box_children_list = array_add(tl.bounding_box_children_list, child.bounding_box_children_list)
				tl.bounding_box_children_list = array_add(tl.bounding_box_children_list, child)
			}
		}
	}
}