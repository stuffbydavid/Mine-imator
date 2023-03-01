/// temp_particles_copy(to)
/// @arg to

function temp_particles_copy(to)
{
	to.pc_spawn_constant = pc_spawn_constant
	to.pc_spawn_amount = pc_spawn_amount
	
	to.pc_spawn_region_use = pc_spawn_region_use
	to.pc_spawn_region_type = pc_spawn_region_type
	to.pc_spawn_region_path = pc_spawn_region_path
	to.pc_spawn_region_sphere_radius = pc_spawn_region_sphere_radius
	to.pc_spawn_region_cube_size = pc_spawn_region_cube_size
	to.pc_spawn_region_box_size = pc_spawn_region_box_size
	to.pc_spawn_region_path_radius = pc_spawn_region_path_radius
	
	to.pc_bounding_box_type = pc_bounding_box_type
	to.pc_bounding_box_ground_z = pc_bounding_box_ground_z
	to.pc_bounding_box_custom_start = pc_bounding_box_custom_start
	to.pc_bounding_box_custom_end = pc_bounding_box_custom_end
	to.pc_bounding_box_relative = pc_bounding_box_relative
	
	to.pc_destroy_at_animation_finish = pc_destroy_at_animation_finish
	to.pc_destroy_at_amount = pc_destroy_at_amount
	to.pc_destroy_at_amount_val = pc_destroy_at_amount_val
	to.pc_destroy_at_time = pc_destroy_at_time
	to.pc_destroy_at_time_seconds = pc_destroy_at_time_seconds
	to.pc_destroy_at_time_israndom = pc_destroy_at_time_israndom
	to.pc_destroy_at_time_random_min = pc_destroy_at_time_random_min
	to.pc_destroy_at_time_random_max = pc_destroy_at_time_random_max
	to.pc_destroy_at_bounding_box = pc_destroy_at_bounding_box
}
