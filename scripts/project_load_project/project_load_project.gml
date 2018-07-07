/// project_load_project([map])
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0
	
project_name = value_get_string(map[?"name"], project_name)
project_author = value_get_string(map[?"author"], project_author)
project_description = value_get_string(map[?"description"], project_description)
project_video_width = value_get_real(map[?"video_width"], project_video_width)
project_video_height = value_get_real(map[?"video_height"], project_video_height)
project_video_template = find_videotemplate(project_video_width, project_video_height)
project_video_keep_aspect_ratio = value_get_real(map[?"video_keep_aspect_ratio"], project_video_keep_aspect_ratio)
project_tempo = value_get_real(map[?"tempo"], project_tempo)
	
var tlmap = map[?"timeline"];
if (ds_map_valid(tlmap))
{
	timeline_repeat = value_get_real(tlmap[?"repeat"], timeline_repeat)
	timeline_show_seconds = value_get_real(tlmap[?"show_seconds"], timeline_show_seconds)
	timeline_marker = value_get_real(tlmap[?"marker"], timeline_marker)
	timeline.list_width = value_get_real(tlmap[?"list_width"], timeline.list_width)
	timeline.hor_scroll.value = value_get_real(tlmap[?"hor_scroll"], timeline.hor_scroll.value)
	timeline_zoom = value_get_real(tlmap[?"zoom"], timeline_zoom)
	timeline_zoom_goal = timeline_zoom
	timeline_region_start = value_get_real(tlmap[?"region_start"], timeline_region_start)
	timeline_region_end = value_get_real(tlmap[?"region_end"], timeline_region_end)
}

var cammap = map[?"work_camera"];
if (ds_map_valid(cammap))
{
	cam_work_focus = value_get_point3D(cammap[?"focus"], cam_work_focus)
	cam_work_angle_xy = value_get_real(cammap[?"angle_xy"], cam_work_angle_xy)
	cam_work_angle_z = value_get_real(cammap[?"angle_z"], cam_work_angle_z)
	cam_work_roll = value_get_real(cammap[?"roll"], cam_work_roll)
	cam_work_zoom = value_get_real(cammap[?"zoom"], cam_work_zoom)
	cam_work_zoom_goal = cam_work_zoom

	cam_work_angle_look_xy = cam_work_angle_xy
	cam_work_angle_look_z = -cam_work_angle_z
	camera_work_set_from()
}