/// project_load_project([map])
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0
	
project_name = json_read_string(map[?"name"], project_name)
project_author = json_read_string(map[?"author"], project_author)
project_description = json_read_string(map[?"description"], project_description)
project_video_width = json_read_real(map[?"video_width"], project_video_width)
project_video_height = json_read_real(map[?"video_height"], project_video_height)
project_video_keep_aspect_ratio = json_read_real(map[?"video_keep_aspect_ratio"], project_video_keep_aspect_ratio)
project_tempo = json_read_real(map[?"tempo"], project_tempo)
	
var tlmap = map[?"timeline"];
if (ds_map_valid(tlmap))
{
	timeline_repeat = json_read_real(tlmap[?"repeat"], timeline_repeat)
	timeline_marker = json_read_real(tlmap[?"marker"], timeline_marker)
	timeline.list_width = json_read_real(tlmap[?"list_width"], timeline.list_width)
	timeline.hor_scroll.value = json_read_real(tlmap[?"hor_scroll"], timeline.hor_scroll.value)
	timeline_zoom = json_read_real(tlmap[?"zoom"], timeline_zoom)
	timeline_zoom_goal = timeline_zoom
	timeline_region_start = json_read_real(tlmap[?"region_start"], timeline_region_start)
	timeline_region_end = json_read_real(tlmap[?"region_end"], timeline_region_end)
}

var cammap = map[?"work_camera"];
if (ds_map_valid(cammap))
{
	cam_work_focus = json_read_array(cammap[?"focus"], cam_work_focus)
	cam_work_angle_xy = json_read_real(cammap[?"angle_xy"], cam_work_angle_xy)
	cam_work_angle_z = json_read_real(cammap[?"angle_z"], cam_work_angle_z)
	cam_work_roll = json_read_real(cammap[?"roll"], cam_work_roll)
	cam_work_zoom = json_read_real(cammap[?"zoom"], cam_work_zoom)
	cam_work_zoom_goal = cam_work_zoom

	cam_work_angle_look_xy = cam_work_angle_xy
	cam_work_angle_look_z = -cam_work_angle_z
	cam_work_set_from()
}