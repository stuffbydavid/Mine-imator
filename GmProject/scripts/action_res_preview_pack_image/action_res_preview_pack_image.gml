/// action_res_preview_pack_image(image)
/// @arg image

function action_res_preview_pack_image(image)
{
	res_preview.pack_image = image
	res_preview.update = true
	res_preview.reset_view = true
}
