/// action_res_preview_pack_model_texture(texture)
/// @arg texture

function action_res_preview_pack_model_texture(texture)
{
	res_preview.pack_model_texture = texture
	res_preview.update = true
	res_preview.reset_view = true
}
