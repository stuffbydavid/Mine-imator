/// action_toolbar_exportmovie_framespersecond(value, add)
/// @arg value
/// @arg add

function action_toolbar_exportmovie_framespersecond(val, add)
{
	popup.framespersecond = add * popup.framespersecond + val
}
