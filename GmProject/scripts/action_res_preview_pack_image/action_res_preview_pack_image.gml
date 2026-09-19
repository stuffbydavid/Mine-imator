/// action_res_preview_pack_image(image)
/// @arg image

function action_res_preview_pack_image(image)
{
	preview_edit.pack_image = image
	preview_edit.update = true
	preview_edit.reset_view = true
}
