/// @arg texture

function texture_free(tex)
{
	if (sprite_exists(tex))
		sprite_delete(tex)
}
