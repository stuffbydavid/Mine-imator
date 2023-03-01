/// CppSeparate void builder_done(Scope<obj_builder>)
/// Clean-up builder data
function builder_done()
{
	if (block_obj != null)
	{
		buffer_delete(block_obj)
		buffer_delete(block_state_id)
		buffer_delete(block_waterlogged)
		ds_grid_destroy(block_render_model)
		ds_list_destroy(block_render_model_multipart)
	}
	build_multithreaded = null
	
	vertex_rgb = c_white
	vertex_alpha = 1
	
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	vertex_emissive = 0
	vertex_subsurface = 0
}
