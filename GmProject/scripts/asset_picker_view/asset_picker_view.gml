/// @desc Scrolls to an asset in the current picker view.
/// @arg picker
/// @arg value
/// @arg [center]

function asset_picker_view(picker, value, center = true)
{
	if (!picker.grid_view)
		return sortlist_view(picker, value, center)

	if (ds_list_find_index(picker.display_list, value) < 0)
		return false

	picker.view_value = value
	picker.center_on_draw = center
	
	return true
}
