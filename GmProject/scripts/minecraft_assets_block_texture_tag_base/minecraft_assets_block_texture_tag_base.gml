/// minecraft_assets_block_texture_tag_base(StringType, StringType)
/// @desc Returns a texture name without a trailing render tag, if it has one.

function minecraft_assets_block_texture_tag_base(texturename, tag)
{
	var taglength, namelength, tagstart;
	taglength = string_length(tag)
	namelength = string_length(texturename)
	if (namelength <= taglength)
		return undefined

	tagstart = namelength - taglength + 1
	if (string_copy(texturename, tagstart, taglength) != tag)
		return undefined

	return string_delete(texturename, tagstart, taglength)
}
