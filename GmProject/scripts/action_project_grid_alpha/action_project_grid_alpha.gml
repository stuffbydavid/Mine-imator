/// action_project_grid_alpha(value, add)
/// @arg value
/// @arg add

function action_project_grid_alpha(val, add)
{
	project_grid_alpha = project_grid_alpha * add + (val / 100)
}