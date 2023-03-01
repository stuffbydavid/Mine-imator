/// tl_select()

function tl_select()
{
	if (selected)
		return 0
	
	selected = true
	
	tl_edit_amount++
	tl_edit = id
	
	tl_update_parent_is_selected()
}
