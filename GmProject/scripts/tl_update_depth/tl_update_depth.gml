/// @desc Updates inherited render depth settings used for real-time sorting before rendering.

function tl_update_depth()
{
	render_depth_custom_current = render_depth_custom
	render_depth_current = render_depth
	
	if (!render_depth_custom_current)
	{
		var par = id;
		while (par.parent != app && par.parent != null && par.inherit_alpha)
		{
			par = par.parent
			if (par.render_depth_custom)
			{
				render_depth_custom_current = true
				render_depth_current = par.render_depth
			}
		}
	}
	
	for (var i = 0; i < ds_list_size(tree_list); i++)
		with (tree_list[|i])
			tl_update_depth()
	
	render_list_default_update = true
}
