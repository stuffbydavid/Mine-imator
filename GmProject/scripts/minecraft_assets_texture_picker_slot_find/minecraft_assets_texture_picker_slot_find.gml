/// minecraft_assets_texture_picker_slot_find(StringType, Array)
/// @desc Returns a contiguous picker slot for a texture name, or -1 when absent.

function minecraft_assets_texture_picker_slot_find(texturename, slotlists)
{
	var slotoffset = 0;
	for (var sheet = 0; sheet < array_length(slotlists); sheet++)
	{
		var slot = ds_list_find_index(slotlists[sheet], texturename);
		if (slot >= 0)
			return slotoffset + slot
		
		slotoffset += ds_list_size(slotlists[sheet])
	}

	return -1
}
