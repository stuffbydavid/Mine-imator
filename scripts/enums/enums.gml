/// enums()
/// @desc Define enumerators used in the project.

// Formats
enum e_project
{
	FORMAT_01		  =	1,
	FORMAT_02		  =	2,
	FORMAT_05		  =	3,
	FORMAT_06		  =	4,
	FORMAT_07_DEMO	  =	5,
	FORMAT_100_DEMO_2 = 6,
	FORMAT_100_DEMO_3 = 7,
	FORMAT_100_DEMO_4 = 8,
	FORMAT_100_DEBUG  = 9,
	FORMAT_100		  = 10,
	FORMAT_105		  = 11,
	FORMAT_105_2	  = 12,
	FORMAT_106		  = 13,
	FORMAT_106_2	  = 14,
	FORMAT_CB_100	  = 20,
	FORMAT_CB_102_PRE = 21,
	FORMAT_CB_102	  = 22,
	FORMAT_CB_103	  = 23,
	FORMAT_110_PRE_1  = 24,
}

enum e_settings
{
	FORMAT_100_DEMO_4 =	0,
	FORMAT_100_DEMO_5 = 1,
	FORMAT_100		  = 2,
	FORMAT_103		  = 3,
	FORMAT_106		  = 4,
	FORMAT_106_2	  = 5,
	FORMAT_106_3	  = 6,
	FORMAT_CB_100	  = 20,
	FORMAT_CB_102	  = 22,
	FORMAT_CE_110	  = 23,
	FORMAT_110_PRE_1  = 24
}

enum e_minecraft_assets
{
	FORMAT_110_PRE_1  = 1
}

// Value types
enum e_value_type
{
	POSITION,
	ROTATION,
	SCALE,
	BEND,
	COLOR,
	PARTICLES,
	LIGHT,
	SPOTLIGHT,
	CAMERA,
	BACKGROUND,
	TEXTURE,
	SOUND,
	TEXT,
	KEYFRAME,
	ROT_POINT,
	HIERARCHY,
	GRAPHICS,
	AUDIO,
	amount
}

// Values
enum e_value
{
	POS_X,
	POS_Y,
	POS_Z,
	ROT_X,
	ROT_Y,
	ROT_Z,
	SCA_X,
	SCA_Y,
	SCA_Z,
	BEND_ANGLE,
	ALPHA,
	RGB_ADD,
	RGB_SUB,
	RGB_MUL,
	HSB_ADD,
	HSB_SUB,
	HSB_MUL,
	MIX_COLOR,
	MIX_PERCENT,
	BRIGHTNESS,
	SPAWN,
	ATTRACTOR,
	FORCE,
	LIGHT_COLOR,
	LIGHT_RANGE,
	LIGHT_FADE_SIZE,
	LIGHT_SPOT_RADIUS,
	LIGHT_SPOT_SHARPNESS,
	CAM_FOV,
	CAM_ROTATE,
	CAM_ROTATE_DISTANCE,
	CAM_ROTATE_ANGLE_XY,
	CAM_ROTATE_ANGLE_Z,
	CAM_DOF,
	CAM_DOF_DEPTH,
	CAM_DOF_RANGE,
	CAM_DOF_FADE_SIZE,
	CAM_SIZE_USE_PROJECT,
	CAM_SIZE_KEEP_ASPECT_RATIO,
	CAM_WIDTH,
	CAM_HEIGHT,
	BG_SKY_MOON_PHASE,
	BG_SKY_TIME,
	BG_SKY_ROTATION,
	BG_SKY_CLOUDS_SPEED,
	BG_SKY_COLOR,
	BG_SKY_CLOUDS_COLOR,
	BG_SUNLIGHT_COLOR,
	BG_AMBIENT_COLOR,
	BG_NIGHT_COLOR,
	BG_FOG_COLOR,
	BG_FOG_DISTANCE,
	BG_FOG_SIZE,
	BG_FOG_HEIGHT,
	BG_WIND_SPEED,
	BG_WIND_STRENGTH,
	BG_TEXTURE_ANI_SPEED,
	TEXTURE_OBJ,
	SOUND_OBJ,
	SOUND_VOLUME,
	SOUND_START,
	SOUND_END,
	TEXT,
	TEXT_FONT,
	VISIBLE,
	TRANSITION,
	amount
} // Update app_startup_lists() when adding values

// Icons
enum icons
{
	NEW_PROJECT, 
	IMPORT_ASSET, 
	OPEN_PROJECT, 
	SAVE_PROJECT, 
	SAVE_PROJECT_AS, 
	EXPORT_MOVIE, 
	EXPORT_IMAGE, 
	VIEW_SECOND, 
	SETTINGS, 
	UNDO, 
	REDO, 
	PLAY, 
	PAUSE, 
	STOP, 
	LOOP, 
	BROWSE, 
	DOWNLOAD_SKIN, 
	IMPORT_FROM_WORLD, 
	SPHERE, 
	CUBE, 
	BOX, 
	CLOSE, 
	CONTROLS, 
	LIGHT, 
	PARTICLES, 
	VIEW_GRID, 
	ASPECT_RATIO, 
	RESET, 
	LOOPS, 
	SEARCH, 
	GRID, 
	SCALE_ALL, 
	ADVANCED_COLORS, 
	RELOAD, 
	CHECK, 
	ARROW_UP, 
	ARROW_RIGHT, 
	ARROW_DOWN, 
	ARROW_LEFT, 
	ARROW_UP_SMALL, 
	ARROW_RIGHT_SMALL, 
	ARROW_DOWN_SMALL, 
	ARROW_LEFT_SMALL, 
	ARROW_UP_TINY, 
	ARROW_RIGHT_TINY, 
	ARROW_DOWN_TINY, 
	ARROW_LEFT_TINY, 
	KEYFRAME, 
	UNLOCK, 
	LOCK, 
	SHOW, 
	HIDE, 
	SOUND, 
	MUTE, 
	COLOR, 
	COLOR_FRAME, 
	CREATE, 
	ANIMATE, 
	COPY, 
	PASTE, 
	FOLDER, 
	IMPORT, 
	EXPORT, 
	DUPLICATE, 
	REMOVE, 
	WALK, 
	RUN, 
	COPY_KEYFRAMES, 
	CUT_KEYFRAMES, 
	PASTE_KEYFRAMES, 
	REMOVE_KEYFRAMES, 
	EXPORT_KEYFRAMES, 
	WEBSITE_SMALL, 
	WEBSITE_MEDIUM, 
	WEBSITE_BIG, 
	FORUMS_SMALL, 
	FORUMS_MEDIUM, 
	FORUMS_BIG, 
	SAVE_SMALL, 
	SAVE_MEDIUM, 
	SAVE_BIG, 
	DOWNLOAD_SMALL, 
	DOWNLOAD_MEDIUM, 
	DOWNLOAD_BIG, 
	CAKE_SMALL, 
	CAKE_MEDIUM, 
	CAKE_BIG, 
	UPGRADE_SMALL, 
	UPGRADE_MEDIUM, 
	UPGRADE_BIG, 
	RENDER_SMALL, 
	RENDER_MEDIUM, 
	RENDER_BIG
}

// Menus
enum e_menu
{
	LIST,
	TIMELINE,
	TRANSITION_LIST
}

// Buttons
enum e_button
{
	NO_TEXT,
	TEXT,
	CAPTION
}

// Options
enum e_option
{
	BROWSE					= -10,
	IMPORT_WORLD			= -11,
	DOWNLOAD_SKIN			= -12,
	DOWNLOAD_SKIN_DONE		= -13,
	IMPORT_ITEM_SHEET_DONE	= -14
}

// Directions
enum e_dir
{
	EAST,
	WEST,
	SOUTH,
	NORTH,
	UP,
	DOWN,
	amount
}

// Parts
enum e_part
{
	RIGHT,
	LEFT,
	FRONT,
	BACK,
	UPPER,
	LOWER,
	amount
}

// Bend
enum e_bend
{
	FORWARD,
	BACKWARD,
	BOTH
}

enum e_shape_bend
{
	BEND,
	LOCK_STATIONARY,
	LOCK_MOVING
}

// Scrollbar
enum e_scroll
{
	VERTICAL,
	HORIZONTAL
}

// Buffer Depth
enum e_block_depth
{
	DEPTH0, // Opaque
	DEPTH1, // Transparent
	DEPTH2, // Semi-transparent
	amount
}

// Buffers
enum e_block_vbuffer
{
	NORMAL,
	ANIMATED,
	GRASS,
	LEAVES,
	amount
}

// Vertex wave
enum e_vertex_wave
{
	NONE,
	Z_ONLY,
	ALL,
}

// NBT
enum e_nbt
{
	TAG_END			= 0,
	TAG_BYTE		= 1,
	TAG_SHORT		= 2,
	TAG_INT			= 3,
	TAG_LONG		= 4,
	TAG_FLOAT		= 5,
	TAG_DOUBLE		= 6,
	TAG_BYTE_ARRAY	= 7,
	TAG_STRING		= 8,
	TAG_LIST		= 9,
	TAG_COMPOUND	= 10,
	TAG_INT_ARRAY	= 11,
	amount
}