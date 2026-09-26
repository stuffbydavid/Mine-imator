/// action_res_preview_pack_model_texture(texture)
/// @arg texture

function action_res_preview_pack_model_texture(texture)
{
	preview_edit.pack_model_texture = texture
	preview_edit.update = true
	preview_edit.reset_view = true
}
