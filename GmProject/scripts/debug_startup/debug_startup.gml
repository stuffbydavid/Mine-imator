/// debug_startup()

function debug_startup()
{
	// Developer options, overwritten by program arguments
	globalvar debug_project, debug_full, debug_advanced;
	globalvar debug_skip_blocks, debug_skip_tangents, debug_show_bones;
	globalvar debug_schematics, debug_names, debug_saveid, debug_unused;
	globalvar debug_info, debug_info_corner, debug_indent, debug_timer;
	
	if (debug_mode)
	{
		debug_project		= file_directory_get() + "dev_project/dev_project.miproject"
		debug_full			= true
		debug_advanced		= true
		debug_skip_blocks	= true
		debug_skip_tangents	= false
		debug_show_bones	= false
		debug_schematics	= false
		debug_names			= false
		debug_saveid		= false
		debug_unused		= false
		debug_info			= 1
	}
	else
	{
		debug_project		= ""
		debug_full			= false
		debug_advanced		= false
		debug_skip_blocks	= false
		debug_skip_tangents	= false
		debug_show_bones	= false
		debug_schematics	= false
		debug_names			= false
		debug_saveid		= false
		debug_unused		= false
		debug_info			= 0
	}
	
	debug_info_corner = 2
	debug_indent = 0
	
	// Benchmarking/testing settings, overwritten by program arguments
	globalvar benchmark_mode, benchmark_exportmovie,
			  benchmark_animate_total_time, benchmark_render_total_time, benchmark_surface_total_time, benchmark_export_total_time;
	globalvar test_project, test_frame_start, test_frame_end, test_all_frames, test_render_mode, test_render_settings, test_debug_pass, test_agent;
			  
	benchmark_mode = false
	benchmark_exportmovie = false

    benchmark_animate_total_time = 0
    benchmark_render_total_time = 0
    benchmark_surface_total_time = 0
    benchmark_export_total_time = 0

    test_project = ""
	test_frame_start = -1
	test_frame_end = -1
	test_all_frames = false
	test_render_mode = ""
	test_render_settings = ""
	test_debug_pass = ""
	test_agent = ""

	// Program arguments not available in release build
	if (is_release())
		return;
	
	// Parse arguments
	var args = program_args_get()
	for (var a = 0; a < array_length(args); a++)
	{
		var arg, nextarg;
		arg = args[a]
		nextarg = ""
		if (a < array_length(args) - 1)
			nextarg = args[a + 1]
			
		// Benchmarking/testing flags
		switch (arg) {
			case "--benchmark_exportmovie": benchmark_exportmovie = true break
			case "--test":
				test_project = nextarg
				benchmark_mode = true
				a++
				break
			case "--start":		test_frame_start = eval(nextarg, -1) a++ break
			case "--end":		test_frame_end = eval(nextarg, -1) a++ break
			case "--all":		test_all_frames = true break
			case "--mode":		test_render_mode = nextarg a++ break
			case "--set":		test_render_settings = nextarg a++ break
			case "--pass":		test_debug_pass = nextarg a++ break
			case "--agent":		test_agent = nextarg a++ break
		}
		
		if (!debug_mode)
			continue;
			
		// Developer flags
		switch (arg) {
			case "--project":			debug_project = nextarg a++ break
			case "--full":				debug_full = true break
			case "--trial":				debug_full = false break
			case "--advanced":			debug_advanced = true break
			case "--simple":			debug_advanced = false break
			case "--skip_blocks":		debug_skip_blocks = true break
			case "--no_skip_blocks":	debug_skip_blocks = false break
			case "--skip_tangents":		debug_skip_tangents = true break
			case "--no_skip_tangents":	debug_skip_tangents = false break
			case "--show_bones":		debug_show_bones = true break
			case "--no_show_bones":		debug_show_bones = false break
			case "--schematics":		debug_schematics = true break
			case "--no_schematics":		debug_schematics = false break
			case "--names":				debug_names = true break
			case "--no_names":			debug_names = false break
			case "--saveid":			debug_saveid = true break
			case "--no_saveid":			debug_saveid = false break
			case "--unused":			debug_unused = true break
			case "--no_unused":			debug_unused = false break
		}
	}
}
