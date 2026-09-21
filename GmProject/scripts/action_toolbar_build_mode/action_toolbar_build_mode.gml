/// action_toolbar_build_mode()

function action_toolbar_build_mode()
{
	if (place_build)
		app_stop_place()
	else
	{
		if (tl_edit_amount > 0)
		{
			tl_deselect_all()
			app_update_tl_edit()
		}
		
		if (bench_tab != e_bench.BLOCK)
			bench_click(e_bench.BLOCK, true)
			
		action_bench_create(false, true)
	}
	
	if (context_menu_name != "")
		context_menu_busy_prev = (place_build ? "place" : "")
}
