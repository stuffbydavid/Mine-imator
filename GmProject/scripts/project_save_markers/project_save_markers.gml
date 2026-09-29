function project_save_markers()
{
	if (ds_list_size(timeline_marker_list) = 0)
		return 0
	
	json_save_array_start("markers")
		
		for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
		{
			var marker = timeline_marker_list[|i];
			
			json_save_object_start()
			
			json_save_var("id", marker.save_id)
			json_save_var("position", marker.pos)
			json_save_var("name", json_string_encode(marker.name))
			json_save_var("color", marker.color)
			
			json_save_object_done()
		}
		
	json_save_array_done()
}
