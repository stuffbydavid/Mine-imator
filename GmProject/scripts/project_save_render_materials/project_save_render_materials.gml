function project_save_render_materials()
{
	json_save_object_start("materials")
		json_save_var("block_emissive", project_render_block_emissive)
		json_save_var("block_subsurface", project_render_block_subsurface)
		json_save_var_bool("water_reflections", project_render_water_reflections)
		json_save_var("water_roughness", project_render_water_roughness)
		json_save_var("water_wave_strength", project_render_water_wave_strength)
		json_save_var("water_wave_speed", project_render_water_wave_speed)
		json_save_var("water_wave_scale", project_render_water_wave_scale)
		json_save_var("water_wave_detail", project_render_water_wave_detail)
		json_save_var_bool("material_maps", project_render_material_maps)
	json_save_object_done()
}
