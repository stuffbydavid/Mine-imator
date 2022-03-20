/// temp_particles_init()
/// @desc Initializes particle creator variables.

function temp_particles_init()
{
	pc_spawn_constant = true
	pc_spawn_amount = 100
	
	pc_spawn_region_use = 0
	pc_spawn_region_type = "sphere"
	pc_spawn_region_path = null
	pc_spawn_region_sphere_radius = 100
	pc_spawn_region_cube_size = 200
	pc_spawn_region_box_size = vec3(200, 200, 200)
	pc_spawn_region_path_radius = 8
	
	pc_bounding_box_type = "none"
	pc_bounding_box_ground_z = 0
	pc_bounding_box_custom_start = vec3(-100, -100, -100)
	pc_bounding_box_custom_end = vec3(100, 100, 100)
	pc_bounding_box_relative = 0
	
	pc_destroy_at_animation_finish = true
	pc_destroy_at_amount = true
	pc_destroy_at_amount_val = 200
	pc_destroy_at_time = 0
	pc_destroy_at_time_seconds = 5
	pc_destroy_at_time_israndom = 0
	pc_destroy_at_time_random_min = 5
	pc_destroy_at_time_random_max = 10
	pc_destroy_at_bounding_box = false
	
	pc_type_list = ds_list_create()
	
	// For type variables, see ptype_event_create()
}
