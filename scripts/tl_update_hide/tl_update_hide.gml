/// tl_update_hide()
/// @desc Hides the children (if they inherit visibility)

if (!hide)
	return 0
	
for (var t = 0; t < ds_list_size(tree_list); t++)
{
	with (tree_list[|t])
	{
		if (inherit_visibility)
		{
			hide = true
			tl_update_hide()
		}
	}
}
