/// action_toolbar_importimage_sheet_size(value, add)
/// @arg value
/// @arg add

function action_toolbar_importimage_sheet_size(val, add)
{
	popup_importimage.sheet_size[axis_edit] = popup_importimage.sheet_size[axis_edit] * add + val
}
