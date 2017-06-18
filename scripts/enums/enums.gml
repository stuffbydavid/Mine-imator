/// enums()
/// @desc Define enumerators used in the project.

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
	BROWSE =				-1,
	IMPORT_WORLD =			-2,
	DOWNLOAD_SKIN =			-3,
	DOWNLOAD_SKIN_DONE =	-4
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

// Icons
enum icons
{
	newproject, 
	importasset, 
	openproject, 
	saveproject, 
	saveprojectas, 
	exportmovie, 
	exportimage, 
	viewsecond, 
	settings, 
	undo, 
	redo, 
	play, 
	pause, 
	stop, 
	loop, 
	browse, 
	downloadskin, 
	importfromworld, 
	sphere, 
	cube, 
	box, 
	close, 
	controls, 
	light, 
	particles, 
	viewgrid, 
	aspectratio, 
	reset, 
	loops, 
	search, 
	grid, 
	scaleall, 
	advancedcolors, 
	reload, 
	check, 
	arrowup, 
	arrowright, 
	arrowdown, 
	arrowleft, 
	arrowupsmall, 
	arrowrightsmall, 
	arrowdownsmall, 
	arrowleftsmall, 
	arrowuptiny, 
	arrowrighttiny, 
	arrowdowntiny, 
	arrowlefttiny, 
	keyframe, 
	unlock, 
	lock, 
	show, 
	hide, 
	sound, 
	mute, 
	color, 
	colorframe, 
	create, 
	animate, 
	copy, 
	paste, 
	folderadd, 
	import, 
	export, 
	duplicate, 
	remove, 
	walk, 
	run, 
	copykeyframes, 
	cutkeyframes, 
	pastekeyframes, 
	removekeyframes, 
	exportkeyframes, 
	websitesmall, 
	websitemedium, 
	websitebig, 
	forumssmall, 
	forumsmedium, 
	forumsbig, 
	savesmall, 
	savemedium, 
	savebig, 
	downloadsmall, 
	downloadmedium, 
	downloadbig, 
	cakesmall, 
	cakemedium, 
	cakebig, 
	upgradesmall, 
	upgrademedium, 
	upgradebig, 
	rendersmall, 
	rendermedium, 
	renderbig
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
	KEYFRAME,
	ROTPOINT,
	HIERARCHY,
	GRAPHICS,
	AUDIO,
	amount
}

// Values
enum e_value
{
	XPOS,
	YPOS,
	ZPOS,
	XROT,
	YROT,
	ZROT,
	XSCA,
	YSCA,
	ZSCA,
	BENDANGLE,
	ALPHA,
	RGBADD,
	RGBSUB,
	RGBMUL,
	HSBADD,
	HSBSUB,
	HSBMUL,
	MIXCOLOR,
	MIXPERCENT,
	BRIGHTNESS,
	SPAWN,
	ATTRACTOR,
	FORCE,
	LIGHTCOLOR,
	LIGHTRANGE,
	LIGHTFADESIZE,
	LIGHTSPOTRADIUS,
	LIGHTSPOTSHARPNESS,
	CAMFOV,
	CAMROTATE,
	CAMROTATEDISTANCE,
	CAMROTATEXYANGLE,
	CAMROTATEZANGLE,
	CAMDOF,
	CAMDOFDEPTH,
	CAMDOFRANGE,
	CAMDOFFADESIZE,
	CAMSIZEUSEPROJECT,
	CAMSIZEKEEPASPECTRATIO,
	CAMWIDTH,
	CAMHEIGHT,
	BGSKYMOONPHASE,
	BGSKYTIME,
	BGSKYROTATION,
	BGSKYCLOUDSSPEED,
	BGSKYCOLOR,
	BGSKYCLOUDSCOLOR,
	BGSUNLIGHTCOLOR,
	BGAMBIENTCOLOR,
	BGNIGHTCOLOR,
	BGFOGCOLOR,
	BGFOGDISTANCE,
	BGFOGSIZE,
	BGFOGHEIGHT,
	BGWINDSPEED,
	BGWINDSTRENGTH,
	BGTEXTUREANISPEED,
	TEXTUREOBJ,
	SOUNDOBJ,
	SOUNDVOLUME,
	SOUNDSTART,
	SOUNDEND,
	VISIBLE,
	TRANSITION,
	amount
}