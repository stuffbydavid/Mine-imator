/// res_update_display_name()

function res_update_display_name()
{
	if (type != e_res_type.FROM_WORLD)
		display_name = filename_new_ext(filename, "")
	else
		display_name = filename
	
	if (type = e_res_type.DOWNLOADED_SKIN)
		display_name = text_get("downloadskinname", display_name)
	
	if (type = e_res_type.MODEL && model_file != null)
		display_name = model_file.name
}
