function app_startup_keybinds()
{
	globalvar keybinds, keybind_edit;
	keybinds = array_create(e_keybind.amount)
	keybind_edit = null
	
	// File
	keybind_register("project/new", e_keybind.PROJECT_NEW, keybind_new("N", true))
	keybind_register("project/open", e_keybind.PROJECT_OPEN, keybind_new("O", true))
	keybind_register("project/save", e_keybind.PROJECT_SAVE, keybind_new("S", true))
	keybind_register("project/save_as", e_keybind.PROJECT_SAVE_AS, keybind_new("S", true, true))
	keybind_register("import_asset", e_keybind.IMPORT_ASSET, keybind_new("I", true))
	
	// Editing
	keybind_register("undo", e_keybind.UNDO, keybind_new("Z", true))
	keybind_register("redo", e_keybind.REDO, keybind_new("Y", true))
	keybind_register("timeline/delete", e_keybind.TIMELINE_DELETE, keybind_new("R", true))
	keybind_register("timeline/duplicate", e_keybind.TIMELINE_DUPLICATE, keybind_new("D", true))
	keybind_register("timeline/select", e_keybind.TIMELINE_SELECT, keybind_new("A", true))
	keybind_register("timeline/hide", e_keybind.TIMELINE_HIDE, keybind_new("H", true))
	keybind_register("timeline/show_hidden", e_keybind.TIMELINE_SHOW_HIDDEN, keybind_new("H", true, false, true))
	keybind_register("create_folder", e_keybind.CREATE_FOLDER, keybind_new("F", true))
	keybind_register("keyframes/create", e_keybind.KEYFRAMES_CREATE, keybind_new("Q", true))
	keybind_register("keyframes/copy", e_keybind.KEYFRAMES_COPY, keybind_new("C", true))
	keybind_register("keyframes/cut", e_keybind.KEYFRAMES_CUT, keybind_new("X", true))
	keybind_register("keyframes/paste", e_keybind.KEYFRAMES_PASTE, keybind_new("V", true))
	keybind_register("keyframes/delete", e_keybind.KEYFRAMES_DELETE, keybind_new(vk_delete))
	keybind_register("keyframes/stretch", e_keybind.KEYFRAMES_STRETCH, keybind_new(null, false, false, true))
	keybind_register("keyframes/scale", e_keybind.KEYFRAMES_SCALE, keybind_new("S", false, false, true))
	
	// Timeline
	keybind_register("play", e_keybind.PLAY, keybind_new(vk_space))
	keybind_register("play_stop", e_keybind.PLAY_STOP, keybind_new(vk_space, false, true))
	keybind_register("play_beginning", e_keybind.PLAY_BEGINNING, keybind_new(vk_enter))
	keybind_register("marker_left", e_keybind.MARKER_LEFT, keybind_new(vk_left))
	keybind_register("marker_right", e_keybind.MARKER_RIGHT, keybind_new(vk_right))
	keybind_register("frame_previous", e_keybind.FRAME_PREVIOUS, keybind_new(vk_left, false, true))
	keybind_register("frame_next", e_keybind.FRAME_NEXT, keybind_new(vk_right, false, true))
	
	// Viewport
	keybind_register("render_mode", e_keybind.RENDER_MODE, keybind_new(vk_f5))
	keybind_register("secondary_view", e_keybind.SECONDARY_VIEW, keybind_new(vk_f6))
	keybind_register("particles_spawn", e_keybind.PARTICLES_SPAWN, keybind_new("X"))
	keybind_register("particles_clear", e_keybind.PARTICLES_CLEAR, keybind_new("C"))
	
	// Tools
	keybind_register("tool/workbench", e_keybind.WORKBENCH, keybind_new(vk_tab))
	keybind_register("tool/build", e_keybind.BUILD_TOOL, keybind_new("B"))
	keybind_register("tool/select", e_keybind.TOOL_SELECT, keybind_new("W"))
	keybind_register("tool/move", e_keybind.TOOL_MOVE, keybind_new("G"))
	keybind_register("tool/rotate", e_keybind.TOOL_ROTATE, keybind_new("R"))
	keybind_register("tool/scale", e_keybind.TOOL_SCALE, keybind_new("S"))
	keybind_register("tool/bend", e_keybind.TOOL_BEND, keybind_new("N"))
	keybind_register("tool/transform", e_keybind.TOOL_TRANSFORM, keybind_new("T"))
	keybind_register("snap", e_keybind.SNAP, keybind_new("F"))
	
	// Navigation
	keybind_register("camera/forward", e_keybind.CAM_FORWARD, keybind_new("W"), true)
	keybind_register("camera/left", e_keybind.CAM_LEFT, keybind_new("A"), true)
	keybind_register("camera/back", e_keybind.CAM_BACK, keybind_new("S"), true)
	keybind_register("camera/right", e_keybind.CAM_RIGHT, keybind_new("D"), true)
	keybind_register("camera/ascend", e_keybind.CAM_ASCEND, keybind_new("E"), true)
	keybind_register("camera/descend", e_keybind.CAM_DESCEND, keybind_new("Q"), true)
	keybind_register("camera/roll_forward", e_keybind.CAM_ROLL_FORWARD, keybind_new("Z"), true)
	keybind_register("camera/roll_back", e_keybind.CAM_ROLL_BACK, keybind_new("C"), true)
	keybind_register("camera/roll_reset", e_keybind.CAM_ROLL_RESET, keybind_new("X"), true)
	keybind_register("camera/reset", e_keybind.CAM_RESET, keybind_new("R"), true)
	keybind_register("camera/fast", e_keybind.CAM_FAST, keybind_new(vk_space), true)
	keybind_register("camera/slow", e_keybind.CAM_SLOW, keybind_new(null, false, true), true)
	keybind_register("camera/view_timeline", e_keybind.CAM_VIEW_TIMELINE, keybind_new("V"))
	keybinds_update_match()
}
