/// action_res_replace()

with (res_edit)
	res_load_browse()
	
with (obj_template)
	if (item_tex = res_edit)
		temp_update_item()

lib_preview.update = true
res_preview.update = true
res_preview.reset_view = true
