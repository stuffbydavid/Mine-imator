/// CppSeparate void world_import_select_world(ScopeAny, StringType, StringType dim = "", BoolType update = false)
/// Selects a world from the given folder. If no dimension is selected the current of the player is selected.
function world_import_select_world(root, dimension = "", update = false)
{
	app.world_import_world_root = root
	app.world_import_world_name = root
	app.world_import_dimension = dimension = "" ? "overworld" : dimension
}
