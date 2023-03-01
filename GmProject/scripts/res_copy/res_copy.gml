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
	to.world_regions_dir = world_regions_dir
	to.world_box_start = world_box_start
	to.world_box_end = world_box_end
	to.world_filter_mode = world_filter_mode
	to.world_filter_array = world_filter_array
	to.scenery_integrity = scenery_integrity
	to.scenery_integrity_invert = scenery_integrity_invert
	to.scenery_palette = scenery_palette
	to.scenery_randomize = scenery_randomize
	to.material_format = material_format
}
