/// @desc Executes when a previously accepted filename is dropped on the window.

function window_drop(files)
{
	asset_load(files[0])
}
