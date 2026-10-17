/// CppSeparate void world_import_update_surface(IntType, IntType, IntType, IntType, IntType, IntType, IntType, IntType)
/// @desc Update the world preview surface drawn at position x,y.
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg confirmx
/// @arg confirmy
/// @arg confirmwidth
/// @arg confirmheight

function world_import_update_surface(xx, yy, width, height, confirmx, confirmy, confirmwidth, confirmheight)
{
	surface_clear(world_import_surface, c_level_middle)
}
