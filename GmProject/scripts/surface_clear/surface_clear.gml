/// @arg surface
/// @arg color
/// @arg [alpha]

function surface_clear(surf, col, alpha = 1)
{
	surface_set_target(surf)
	{
		draw_clear_alpha(col, alpha)
	}
	surface_reset_target()
}