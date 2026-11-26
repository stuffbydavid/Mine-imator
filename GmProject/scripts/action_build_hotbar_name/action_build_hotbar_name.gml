/// @desc Renames the selected hotbar.
/// @arg name

function action_build_hotbar_name(name)
{
	build_hotbar_current.name = name
	sortlist_update(build_hotbars.list)
}
