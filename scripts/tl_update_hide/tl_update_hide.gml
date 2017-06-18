/// tl_update_hide()
/// @desc Hides the children (if they inherit visibility)

if (!hide)
    return 0
    
for (var t = 0; t < tree_amount; t++)
{
    with (tree[t])
	{
        if (inherit_visibility)
		{
            hide = true
            tl_update_hide()
        }
    }
}
