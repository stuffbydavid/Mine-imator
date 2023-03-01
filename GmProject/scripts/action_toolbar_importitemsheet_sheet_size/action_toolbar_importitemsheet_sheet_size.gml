/// action_toolbar_importitemsheet_sheet_size(value, add)
/// @arg value
/// @arg add

function action_toolbar_importitemsheet_sheet_size(val, add)
{
	popup_importitemsheet.sheet_size[axis_edit] = popup_importitemsheet.sheet_size[axis_edit] * add + val
}
