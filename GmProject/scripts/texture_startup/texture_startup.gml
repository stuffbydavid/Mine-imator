/// @desc Initializes resource texture tracking and logical GameMaker page indices.

function texture_startup()
{
	globalvar texture_res_map, texture_page_current, texture_page_count;
	
	texture_res_map = ds_map_create()
	
	texture_page_current = texture_page_ui
	texture_page_count = 2
}
