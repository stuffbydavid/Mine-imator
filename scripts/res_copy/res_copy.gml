/// res_copy(to)
/// @arg to

function res_copy(to)
{
	to.type = type
	to.filename = filename
	to.display_name = display_name
	to.player_skin = player_skin
	to.item_sheet_size = array_copy_1d(item_sheet_size)
	to.scenery_tl_add = scenery_tl_add
	to.scenery_download_skins = scenery_download_skins
}
