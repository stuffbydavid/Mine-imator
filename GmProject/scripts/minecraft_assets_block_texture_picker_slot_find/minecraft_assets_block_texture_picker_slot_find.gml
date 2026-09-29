/// @desc Returns the contiguous block picker slot for a texture name, or -1 when absent.

function minecraft_assets_block_texture_picker_slot_find(texturename)
{
	var slotoffset = 0;
	for (var sheet = 0; sheet < e_block_sheet.static_amount; sheet++)
	{
		var slot = ds_list_find_index(mc_assets.block_texture_list[sheet], texturename);
		if (slot >= 0)
			return slotoffset + slot
		
		slotoffset += ds_list_size(mc_assets.block_texture_list[sheet])
	}

	var slot = ds_list_find_index(mc_assets.block_texture_ani_list, texturename);
	return slot >= 0 ? slotoffset + slot : -1
}
