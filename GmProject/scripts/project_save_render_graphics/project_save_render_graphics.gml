function project_save_render_graphics()
{
	json_save_object_start("graphics")
	
		json_save_var("render_distance", project_render_distance)
		json_save_var_bool("texture_filtering", project_render_texture_filtering)
		json_save_var_bool("transparent_block_texture_filtering", project_render_transparent_block_texture_filtering)
		json_save_var("texture_filtering_level", project_render_texture_filtering_level)
		json_save_var("bend_style", project_bend_style)
		json_save_var_bool("opaque_leaves", project_render_opaque_leaves)
		json_save_var_bool("liquid_animation", project_render_liquid_animation)
		json_save_var("render_alpha_mode", project_render_alpha_mode)
		
	json_save_object_done()
}
