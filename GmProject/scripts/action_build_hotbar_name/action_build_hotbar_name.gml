/// @desc Renames the selected hotbar.
/// @arg name

function action_build_hotbar_name(name)
{
	var hotbar = build_hotbars.list.list[|build_hotbars.selected];
	hotbar.name = name
	sortlist_update(build_hotbars.list)
}
