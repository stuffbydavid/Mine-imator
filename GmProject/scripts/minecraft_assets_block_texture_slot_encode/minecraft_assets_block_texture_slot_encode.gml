/// @desc Encodes a texture-sheet page and its cell slot for the texture lookup maps.

function minecraft_assets_block_texture_slot_encode(texturepage, slot)
{
	return slot * e_block_sheet.amount + texturepage
}
