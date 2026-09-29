/// @desc Decodes a contiguous block picker slot, including the animated page.

function minecraft_assets_block_texture_picker_slot_decode(slot)
{
	for (var sheet = 0; sheet < e_block_sheet.static_amount; sheet++)
	{
		var slotcount = ds_list_size(mc_assets.block_texture_list[sheet]);
		if (slot < slotcount)
			return array(sheet, slot)
		slot -= slotcount
	}

	if (slot < ds_list_size(mc_assets.block_texture_ani_list))
		return [e_block_sheet.ANIMATED, slot]
	
	return array(-1, -1)
}
