/// app_startup_keybinds()

function app_startup_keybinds()
{
	globalvar keybinds, keybind_edit;
	keybinds = array_create(e_keybind.amount)
	keybind_edit = null
	
	enum e_keybind_key
	{
		CHAR,
		CTRL,
		SHIFT,
		ALT
	}
	
	enum e_keybind
	{
		// File
		PROJECT_NEW,
		PROJECT_OPEN,
		PROJECT_SAVE,
		PROJECT_SAVE_AS,
		IMPORT_ASSET,
		
		// Editing
		UNDO,
		REDO,
		TIMELINE_DELETE,
		TIMELINE_DUPLICATE,
		TIMELINE_SELECT,
		CREATE_FOLDER,
		KEYFRAMES_CREATE,
		KEYFRAMES_COPY,
		KEYFRAMES_CUT,
		KEYFRAMES_PASTE,
		KEYFRAMES_DELETE,
		TIMELINE_HIDE,
		TIMELINE_SHOW_HIDDEN,
		
		// Timeline
		PLAY,
		PLAY_STOP,
		PLAY_BEGINNING,
		MARKER_RIGHT,
		MARKER_LEFT,
		FRAME_PREVIOUS,
		FRAME_NEXT,
		
		// Viewport
		RENDER_MODE,
		SECONDARY_VIEW,
		PARTICLES_SPAWN,
		PARTICLES_CLEAR,
		
		// Tools
		TOOL_SELECT,
		TOOL_MOVE,
		TOOL_ROTATE,
		TOOL_SCALE,
		TOOL_BEND,
		TOOL_TRANSFORM,
		SNAP,
		
		// Navigation
		CAM_FORWARD,
		CAM_BACK,
		CAM_LEFT,
		CAM_RIGHT,
		CAM_ASCEND,
		CAM_DESCEND,
		CAM_ROLL_FORWARD,
		CAM_ROLL_BACK,
		CAM_RESET,
		CAM_ROLL_RESET,
		CAM_FAST,
		CAM_SLOW,
		CAM_VIEW_TIMELINE,
		
		amount
	}
	
	// File
	keybind_register("projectnew", e_keybind.PROJECT_NEW, keybind_new("N", true))
	keybind_register("projectopen", e_keybind.PROJECT_OPEN, keybind_new("O", true))
	keybind_register("projectsave", e_keybind.PROJECT_SAVE, keybind_new("S", true))
	keybind_register("projectsaveas", e_keybind.PROJECT_SAVE_AS, keybind_new("S", true, true))
	keybind_register("importasset", e_keybind.IMPORT_ASSET, keybind_new("I", true))
	
	// Editing
	keybind_register("undo", e_keybind.UNDO, keybind_new("Z", true))
	keybind_register("redo", e_keybind.REDO, keybind_new("Y", true))
	keybind_register("timelinedelete", e_keybind.TIMELINE_DELETE, keybind_new("R", true))
	keybind_register("timelineduplicate", e_keybind.TIMELINE_DUPLICATE, keybind_new("D", true))
	keybind_register("timelineselect", e_keybind.TIMELINE_SELECT, keybind_new("A", true))
	keybind_register("timelinehide", e_keybind.TIMELINE_HIDE, keybind_new("H", true))
	keybind_register("timelineshowhidden", e_keybind.TIMELINE_SHOW_HIDDEN, keybind_new("H", true, false, true))
	keybind_register("createfolder", e_keybind.CREATE_FOLDER, keybind_new("F", true))
	keybind_register("keyframescreate", e_keybind.KEYFRAMES_CREATE, keybind_new("Q", true))
	keybind_register("keyframescopy", e_keybind.KEYFRAMES_COPY, keybind_new("C", true))
	keybind_register("keyframescut", e_keybind.KEYFRAMES_CUT, keybind_new("X", true))
	keybind_register("keyframespaste", e_keybind.KEYFRAMES_PASTE, keybind_new("V", true))
	keybind_register("keyframesdelete", e_keybind.KEYFRAMES_DELETE, keybind_new(vk_delete))
	
	// Timeline
	keybind_register("play", e_keybind.PLAY, keybind_new(vk_space))
	keybind_register("playstop", e_keybind.PLAY_STOP, keybind_new(vk_space, false, true))
	keybind_register("playbeginning", e_keybind.PLAY_BEGINNING, keybind_new(vk_enter))
	keybind_register("markerleft", e_keybind.MARKER_LEFT, keybind_new(vk_left))
	keybind_register("markerright", e_keybind.MARKER_RIGHT, keybind_new(vk_right))
	keybind_register("frameprevious", e_keybind.FRAME_PREVIOUS, keybind_new(vk_left, false, true))
	keybind_register("framenext", e_keybind.FRAME_NEXT, keybind_new(vk_right, false, true))
	
	// Viewport
	keybind_register("rendermode", e_keybind.RENDER_MODE, keybind_new(vk_f5))
	keybind_register("secondaryview", e_keybind.SECONDARY_VIEW, keybind_new(vk_f6))
	keybind_register("particlesspawn", e_keybind.PARTICLES_SPAWN, keybind_new("X"))
	keybind_register("particlesclear", e_keybind.PARTICLES_CLEAR, keybind_new("C"))
	
	// Tools
	keybind_register("toolselect", e_keybind.TOOL_SELECT, keybind_new("W"))
	keybind_register("toolmove", e_keybind.TOOL_MOVE, keybind_new("G"))
	keybind_register("toolrotate", e_keybind.TOOL_ROTATE, keybind_new("R"))
	keybind_register("toolscale", e_keybind.TOOL_SCALE, keybind_new("S"))
	keybind_register("toolbend", e_keybind.TOOL_BEND, keybind_new("B"))
	keybind_register("tooltransform", e_keybind.TOOL_TRANSFORM, keybind_new("T"))
	keybind_register("snap", e_keybind.SNAP, keybind_new("F"))
	
	// Navigation
	keybind_register("camforward", e_keybind.CAM_FORWARD, keybind_new("W"), true)
	keybind_register("camleft", e_keybind.CAM_LEFT, keybind_new("A"), true)
	keybind_register("camback", e_keybind.CAM_BACK, keybind_new("S"), true)
	keybind_register("camright", e_keybind.CAM_RIGHT, keybind_new("D"), true)
	keybind_register("camascend", e_keybind.CAM_ASCEND, keybind_new("E"), true)
	keybind_register("camdescend", e_keybind.CAM_DESCEND, keybind_new("Q"), true)
	keybind_register("camrollforward", e_keybind.CAM_ROLL_FORWARD, keybind_new("Z"), true)
	keybind_register("camrollback", e_keybind.CAM_ROLL_BACK, keybind_new("C"), true)
	keybind_register("camrollreset", e_keybind.CAM_ROLL_RESET, keybind_new("X"), true)
	keybind_register("camreset", e_keybind.CAM_RESET, keybind_new("R"), true)
	keybind_register("camfast", e_keybind.CAM_FAST, keybind_new(vk_space), true)
	keybind_register("camslow", e_keybind.CAM_SLOW, keybind_new(null, false, true), true)
	keybind_register("camviewtimeline", e_keybind.CAM_VIEW_TIMELINE, keybind_new("V"))
	
	keybinds_update_match()
}
