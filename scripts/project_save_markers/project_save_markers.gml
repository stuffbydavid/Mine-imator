/// project_save_markers()

function project_save_markers()
{
	if (ds_list_size(timeline_marker_list) = 0)
		return 0
	
	json_save_array_start("markers")
		
		for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
		{
			json_save_object_start()
			
			with (timeline_marker_list[|i])
			{
				json_save_var("id", save_id)
				json_save_var("position", pos)
				json_save_var("name", name)
				json_save_var("color", color)
			}
			
			json_save_object_done()
		}
		
	json_save_array_done()
}
