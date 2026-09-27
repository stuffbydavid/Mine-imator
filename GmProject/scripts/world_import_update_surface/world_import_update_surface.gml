/// CppSeparate void world_import_update_surface(IntType, IntType, IntType, IntType, IntType, IntType, IntType, IntType)
/// Update the world preview surface drawn at position x,y.
function world_import_update_surface(xx, yy, width, height, confirmx, confirmy, confirmwidth, confirmheight)
{
	surface_set_target(world_import_surface)
	draw_clear(c_level_middle)
	surface_reset_target()
}
