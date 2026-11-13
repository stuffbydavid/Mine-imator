function tl_value_set_done()
{
	with (app)
		tl_update_matrix()
	
	view_changed()
}
