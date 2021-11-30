/// app_startup_keybinds()

function app_startup_keybinds()
{
	globalvar keybinds, keybind_edit, keybind_active;
	keybinds = array_create(e_keybind.amount)
	keybind_edit = null
	keybind_active = null
	
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
		INSTANCE_DELETE,
		INSTANCE_DUPLICATE,
		INSTANCE_SELECT,
		CREATE_FOLDER,
		KEYFRAMES_CREATE,
		KEYFRAMES_COPY,
		KEYFRAMES_CUT,
		KEYFRAMES_PASTE,
		KEYFRAMES_DELETE,
		INSTANCE_HIDE,
		INSTANCE_SHOW_HIDDEN,
		
		// Timeline
		PLAY,
		PLAY_BEGINNING,
		MARKER_RIGHT,
		MARKER_LEFT,
		
		// Viewport
		RENDER_MODE,
		PARTICLES_SPAWN,
		PARTICLES_CLEAR,
		SECONDARY_VIEW,
		
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
		CAM_VIEW_INSTANCE,
		
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
	keybind_register("instancedelete", e_keybind.INSTANCE_DELETE, keybind_new("R", true))
	keybind_register("instanceduplicate", e_keybind.INSTANCE_DUPLICATE, keybind_new("D", true))
	keybind_register("instanceselect", e_keybind.INSTANCE_SELECT, keybind_new("A", true))
	keybind_register("instancehide", e_keybind.INSTANCE_HIDE, keybind_new("H", true))
	keybind_register("instanceshowhidden", e_keybind.INSTANCE_SHOW_HIDDEN, keybind_new("H", true, false, true))
	keybind_register("createfolder", e_keybind.CREATE_FOLDER, keybind_new("F", true))
	keybind_register("keyframescreate", e_keybind.KEYFRAMES_CREATE, keybind_new("Q", true))
	keybind_register("keyframescopy", e_keybind.KEYFRAMES_COPY, keybind_new("C", true))
	keybind_register("keyframescut", e_keybind.KEYFRAMES_CUT, keybind_new("X", true))
	keybind_register("keyframespaste", e_keybind.KEYFRAMES_PASTE, keybind_new("V", true))
	keybind_register("keyframesdelete", e_keybind.KEYFRAMES_DELETE, keybind_new(vk_delete))
	
	// Timeline
	keybind_register("play", e_keybind.PLAY, keybind_new(vk_space))
	keybind_register("playbeginning", e_keybind.PLAY_BEGINNING, keybind_new(vk_enter))
	keybind_register("markerleft", e_keybind.MARKER_LEFT, keybind_new(vk_left), true)
	keybind_register("markerright", e_keybind.MARKER_RIGHT, keybind_new(vk_right), true)
	
	// Viewport
	keybind_register("rendermode", e_keybind.RENDER_MODE, keybind_new(vk_f5))
	keybind_register("particlesspawn", e_keybind.PARTICLES_SPAWN, keybind_new("X"))
	keybind_register("particlesclear", e_keybind.PARTICLES_CLEAR, keybind_new("C"))
	keybind_register("secondaryview", e_keybind.SECONDARY_VIEW, keybind_new(vk_f6))
	
	// Tools
	keybind_register("toolselect", e_keybind.TOOL_SELECT, keybind_new("W"))
	keybind_register("toolmove", e_keybind.TOOL_MOVE, keybind_new("G"))
	keybind_register("toolrotate", e_keybind.TOOL_ROTATE, keybind_new("R"))
	keybind_register("toolscale", e_keybind.TOOL_SCALE, keybind_new("S"))
	keybind_register("toolbend", e_keybind.TOOL_BEND, keybind_new("B"))
	keybind_register("tooltransform", e_keybind.TOOL_TRANSFORM, keybind_new("T"))
	keybind_register("snap", e_keybind.SNAP, keybind_new("F"))
	
	// Navigation
	keybind_register("camforward", e_keybind.CAM_FORWARD, keybind_new("W"), true, false)
	keybind_register("camleft", e_keybind.CAM_LEFT, keybind_new("A"), true, false)
	keybind_register("camback", e_keybind.CAM_BACK, keybind_new("S"), true, false)
	keybind_register("camright", e_keybind.CAM_RIGHT, keybind_new("D"), true, false)
	keybind_register("camascend", e_keybind.CAM_ASCEND, keybind_new("E"), true, false)
	keybind_register("camdescend", e_keybind.CAM_DESCEND, keybind_new("Q"), true, false)
	keybind_register("camrollforward", e_keybind.CAM_ROLL_FORWARD, keybind_new("Z"), true, false)
	keybind_register("camrollback", e_keybind.CAM_ROLL_BACK, keybind_new("C"), true, false)
	keybind_register("camrollreset", e_keybind.CAM_ROLL_RESET, keybind_new("X"), true, false)
	keybind_register("camreset", e_keybind.CAM_RESET, keybind_new("R"), true, false)
	keybind_register("camfast", e_keybind.CAM_FAST, keybind_new(vk_space), true, false)
	keybind_register("camslow", e_keybind.CAM_SLOW, keybind_new(null, false, true), true, false)
	keybind_register("camviewinstance", e_keybind.CAM_VIEW_INSTANCE, keybind_new("V"), false, false)
	
	keybinds_update_match()
}
