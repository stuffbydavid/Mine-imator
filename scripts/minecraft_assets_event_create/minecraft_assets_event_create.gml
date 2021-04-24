/// minecraft_version_event_create()

function minecraft_assets_event_create()
{
	version = ""
	
	model_name_map = ds_map_create()
	
	char_list = ds_list_create()
	special_block_list = ds_list_create()
	
	block_list = ds_list_create()
	block_name_map = ds_map_create()
	block_id_map = ds_map_create()
	block_liquid_slot_map = ds_map_create()
	
	model_texture_list = ds_list_create()
	block_texture_list = ds_list_create()
	block_texture_ani_list = ds_list_create()
	block_texture_color_map = ds_map_create()
	item_texture_list = ds_list_create()
	particle_texture_list = ds_list_create()
}
