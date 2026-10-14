/// @desc Renders an item with minimal settings and materials, intended for selection, scene test and depth passes.
/// @arg vertexbuffer
/// @arg diffuse
/// @arg sheet
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg [realtime]

function render_world_item_fast(vbuf, resdif, sheet, is3d, facecamera, bounce, rotate, realtime = false)
{
	resdif = res_eval(resdif)
	render_apply_res(resdif)
	
	if (facecamera || bounce || rotate)
		matrix_set(matrix_world, render_world_get_item_transform(matrix_get(matrix_world), facecamera, bounce, rotate, true, is3d, realtime))
	
	if (resdif.item_sheet_texture[sheet] != null)
		render_set_texture(resdif, resdif.item_sheet_texture[sheet])
	else
		render_set_texture(resdif, resdif.texture)
	
	vbuffer_render(vbuf)
	
	return 0
}
