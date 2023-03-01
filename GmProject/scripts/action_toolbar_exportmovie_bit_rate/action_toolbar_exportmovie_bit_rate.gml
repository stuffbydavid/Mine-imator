/// action_toolbar_exportmovie_bit_rate(value, add)
/// @arg value
/// @arg add

function action_toolbar_exportmovie_bit_rate(val, add)
{
	popup.bit_rate = add * popup.bit_rate + val
}
