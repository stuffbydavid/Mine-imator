/// bench_list_height(list)
/// @desc Calculates and returns the active workbench list height

function bench_list_height(slist)
{
	var height, minimum, fixed;
	minimum = 46 + (ui_small_height + 2) * slist.header_show + slist.height_items * ui_small_height
	fixed = bench_settings.height_fixed[bench_tab]
	height = minimum
	if (fixed > 0)
	{
		height = max(0, bench_settings.height - fixed)
		if (slist.height_percent < 1 && height >= minimum)
			height = clamp(floor((bench_settings.height - bench_settings.height_fixed_base[bench_tab]) * slist.height_percent), minimum, height)
	}

	bench_settings.list_height = height
	bench_settings.list_minimum_height = minimum
	return height
}
