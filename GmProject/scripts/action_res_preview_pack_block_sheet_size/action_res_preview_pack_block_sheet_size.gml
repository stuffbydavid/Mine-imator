/// action_res_preview_pack_block_sheet_size(size)
/// @arg size

function action_res_preview_pack_block_sheet_size(size)
{
	res_preview.pack_block_sheet_size = size
	res_preview.update = true
	res_preview.reset_view = true
}
