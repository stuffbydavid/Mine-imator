/// save_id_create()
/// @desc Creates a new unique save ID.

random_set_seed(save_id_seed)

var saveid;
do
{
	saveid = ""
	repeat (16)
		saveid += chr(choose(
			irandom_range(ord("0"), ord("9")),
			irandom_range(ord("A"), ord("Z"))
		))
}
until (save_id_find(saveid) = null)

save_id_seed++

return saveid