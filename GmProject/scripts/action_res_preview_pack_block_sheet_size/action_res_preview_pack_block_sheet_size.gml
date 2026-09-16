/// action_res_preview_pack_block_sheet_size(size)
/// @arg size

function action_res_preview_pack_block_sheet_size(size)
{
	preview_edit.pack_block_sheet_size = size
	preview_edit.update = true
	preview_edit.reset_view = true
}
