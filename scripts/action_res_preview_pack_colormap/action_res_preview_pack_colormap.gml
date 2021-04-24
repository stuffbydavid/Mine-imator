/// action_res_preview_pack_colormap(colormap)
/// @arg colormap

function action_res_preview_pack_colormap(colormap)
{
	res_preview.pack_colormap = colormap
	res_preview.update = true
	res_preview.reset_view = true
}
