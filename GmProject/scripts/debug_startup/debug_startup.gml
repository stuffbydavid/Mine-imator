/// debug_startup()
function debug_startup()
{
	// Developer options, overwritten by program arguments
	globalvar dev_mode, dev_mode_project, dev_mode_full, dev_mode_advanced;
	globalvar dev_mode_skip_blocks, dev_mode_skip_tangents, dev_mode_show_bones;
	globalvar dev_mode_debug_schematics, dev_mode_debug_names, dev_mode_debug_saveid, dev_mode_debug_unused;
	
	dev_mode = is_debug()
	if (dev_mode)
	{
		dev_mode_project				= file_directory + "dev_project/dev_project.miproject"
		dev_mode_full					= true
		dev_mode_advanced				= true
		dev_mode_skip_blocks			= false
		dev_mode_skip_tangents			= false
		dev_mode_show_bones				= false
		dev_mode_debug_schematics		= false
		dev_mode_debug_names			= false
		dev_mode_debug_saveid			= false
		dev_mode_debug_unused			= false
	}
	else
	{
		dev_mode_project				= ""
		dev_mode_full					= false
		dev_mode_advanced				= false
		dev_mode_skip_blocks			= false
		dev_mode_skip_tangents			= false
		dev_mode_show_bones				= false
		dev_mode_debug_schematics		= false
		dev_mode_debug_names			= false
		dev_mode_debug_saveid			= false
		dev_mode_debug_unused			= false
	}
	
	// Debug info
	globalvar debug_indent, debug_info, debug_info_corner, debug_timer;
	debug_indent = 0
	debug_info = dev_mode ? 1 : 0
	debug_info_corner = 2
	
	// Benchmark project, overwritten by program arguments
	globalvar benchmark_project, benchmark_exportmovie, benchmark_mode,
			  benchmark_animate_total_time, benchmark_render_total_time, benchmark_surface_total_time, benchmark_export_total_time;
			  
	benchmark_project = ""
	benchmark_exportmovie = false
	
	benchmark_mode = false
	benchmark_animate_total_time = 0
	benchmark_render_total_time = 0
	benchmark_surface_total_time = 0
	benchmark_export_total_time = 0
	
	// Parse arguments
	var args = program_args_get()
	for (var a = 0; a < array_length(args); a++)
	{
		var arg, nextarg;
		arg = args[a]
		nextarg = ""
		if (a < array_length(args) - 1)
			nextarg = args[a + 1]
			
		// Benchmarking flags
		switch (arg) {
			case "--benchmark_project":	
				benchmark_project = nextarg
				benchmark_mode = true
				dev_mode_skip_blocks = true
				break
			case "--benchmark_exportmovie": benchmark_exportmovie = true break
		}
		
		if (!is_debug())
			continue;
			
		// Developer flags
		switch (arg) {
			case "--no_dev_mode":					dev_mode = false break
			case "--dev_mode_project":				dev_mode_project = nextarg break
			case "--dev_mode_full":					dev_mode_full = true break
			case "--dev_mode_trial":				dev_mode_full = false break
			case "--dev_mode_advanced":				dev_mode_advanced = true break
			case "--dev_mode_simple":				dev_mode_advanced = false break
			case "--dev_mode_skip_blocks":			dev_mode_skip_blocks = true break
			case "--no_dev_mode_skip_blocks":		dev_mode_skip_blocks = false break
			case "--dev_mode_skip_tangents":		dev_mode_skip_tangents = true break
			case "--no_dev_mode_skip_tangents":		dev_mode_skip_tangents = false break
			case "--dev_mode_show_bones":			dev_mode_show_bones = true break
			case "--no_dev_mode_show_bones":		dev_mode_show_bones = false break
			case "--dev_mode_debug_schematics":		dev_mode_debug_schematics = true break
			case "--no_dev_mode_debug_schematics":	dev_mode_debug_schematics = false break
			case "--dev_mode_debug_names":			dev_mode_debug_names = true break
			case "--no_dev_mode_debug_names":		dev_mode_debug_names = false break
			case "--dev_mode_debug_saveid":			dev_mode_debug_saveid = true break
			case "--no_dev_mode_debug_saveid":		dev_mode_debug_saveid = false break
			case "--dev_mode_debug_unused":			dev_mode_debug_unused = true break
			case "--no_dev_mode_debug_unused":		dev_mode_debug_unused = false break
		}
	}
}