/// @desc Returns the sheet index and sheet-local slot for a contiguous picker slot.

function minecraft_assets_texture_picker_slot_decode(slot, slotlists)
{
	for (var sheet = 0; sheet < array_length(slotlists); sheet++)
	{
		var slotcount = ds_list_size(slotlists[sheet]);
		if (slot < slotcount)
			return array(sheet, slot)
		
		slot -= slotcount
	}

	return array(-1, -1)
}
