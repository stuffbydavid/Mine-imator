/// CppSeparate void builder_done(Scope<obj_builder>)
/// @desc Clean-up builder data.

function builder_done()
{
	if (block_obj != null)
	{
		buffer_delete(block_obj)
		buffer_delete(block_state_id)
		buffer_delete(block_waterlogged)
		ds_list_destroy(block_render_model_multipart)

		block_obj = null
		block_state_id = null
		block_waterlogged = null
	}
	
	block_render_model = []
	block_meshes = []
	
	build_multithreaded = null
	build_transform = false
	
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	vertex_emissive = 0
	vertex_subsurface_color_index = 0
}
