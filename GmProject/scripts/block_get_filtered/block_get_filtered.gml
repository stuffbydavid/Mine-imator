/// CppSeparate BoolType block_get_filtered(IntType, IntType)
/// @desc Check a block against a prepared resource filter, returning whether it should be removed.
/// @arg resource
/// @arg block

function block_get_filtered(res, block)
{
	if (block = null)
		return true

	if (!res.scenery_filter_enabled)
		return false

	var filtered = false;
	if (block.block_id >= 0 && block.block_id < array_length(res.scenery_filter_mask))
		filtered = !res.scenery_filter_mask[block.block_id]

	if (res.scenery_filter_mode = e_block_filter.REMOVE)
		return !filtered

	return filtered
}
