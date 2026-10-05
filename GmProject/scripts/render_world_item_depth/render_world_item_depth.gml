/// @desc Renders an item in a depth pass.
/// @arg vertexbuffer
/// @arg diffuse
/// @arg sheet
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg [realtime]

function render_world_item_depth(vbuf, resdif, sheet, is3d, facecamera, bounce, rotate, realtime = false)
{
	resdif = res_eval(resdif)
	render_apply_res(resdif)
	
	if (facecamera || bounce || rotate)
		matrix_set(matrix_world, render_world_item_transform(matrix_get(matrix_world), facecamera, bounce, rotate, true, is3d, realtime))
	
	if (resdif.item_sheet_texture[sheet] != null)
		render_set_texture(resdif.item_sheet_texture[sheet])
	else
		render_set_texture(resdif.texture)
	
	vbuffer_render(vbuf)
	
	return 0
}
