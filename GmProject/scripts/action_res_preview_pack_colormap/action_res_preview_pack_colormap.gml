/// action_res_preview_pack_colormap(colormap)
/// @arg colormap

function action_res_preview_pack_colormap(colormap)
{
	preview_edit.pack_colormap = colormap
	preview_edit.update = true
	preview_edit.reset_view = true
}
