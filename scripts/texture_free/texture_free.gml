/// texture_free(texture)
/// @arg texture

function texture_free(tex)
{
	if (sprite_exists(tex))
		return sprite_delete(tex)
}
