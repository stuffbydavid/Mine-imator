/// project_save_markers()

function project_save_markers()
{
	if (ds_list_size(timeline_marker_list) = 0)
		return 0
	
	// Hacky fix for bizzare marker saving bug
	var saved = [];
	var m;
	
	json_save_array_start("markers")
		
		for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
		{
			m = timeline_marker_list[|i]
			
			if (array_contains(saved, m.save_id))
				continue
			else
				array_add(saved, m.save_id)
			
			json_save_object_start()
			
			json_save_var("id", m.save_id)
			json_save_var("position", m.pos)
			json_save_var("name", m.name)
			json_save_var("color", m.color)
			
			json_save_object_done()
		}
		
	json_save_array_done()
}
