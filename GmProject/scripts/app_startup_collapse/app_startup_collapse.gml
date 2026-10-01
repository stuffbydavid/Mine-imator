function app_startup_collapse()
{
	globalvar collapse_map, collapse_ani, collapse_groups;
	collapse_ani = 1
	collapse_groups = 0
	
	collapse_map = ds_map_create()
	
	collapse_register("file")
	collapse_register("edit")
	collapse_register("tools")
	collapse_register("viewport")
	collapse_register("timeline")
	collapse_register("camera")

	collapse_register("settings/backup")
	collapse_register("settings/watermark")
	
	
	collapse_register("render/ssao")
	collapse_register("render/shadows")
	collapse_register("render/subsurface")
	collapse_register("render/indirect")
	collapse_register("render/reflections")
	collapse_register("render/glow")
	collapse_register("render/aa")
	collapse_register("render/render_dof")
	collapse_register("render/light_management")
	collapse_register("render/models_scenery")
	collapse_register("render/texture_filtering")
	collapse_register("render/glint")
	collapse_register("render/water_material")
	
	collapse_register("environment/biome", true)
	collapse_register("environment/sky")
	collapse_register("environment/clouds")
	collapse_register("environment/ground")
	collapse_register("environment/fog")
	collapse_register("environment/wind")
	
	collapse_register("frame_editor/itemslot")
	
	collapse_register("frame_editor/follow_path")
	collapse_register("frame_editor/rotatepoint")
	collapse_register("frame_editor/ik")
	
	collapse_register("frame_editor/fade", true)
	collapse_register("frame_editor/shake", true)
	collapse_register("frame_editor/dof", true)
	collapse_register("frame_editor/dof_bokeh")
	collapse_register("frame_editor/dof_fringe", true)
	collapse_register("frame_editor/bloom", true)
	collapse_register("frame_editor/lens_dirt", true)
	collapse_register("frame_editor/grain", true)
	collapse_register("frame_editor/vignette", true)
	collapse_register("frame_editor/ca", true)
	collapse_register("frame_editor/distort", true)
	collapse_register("frame_editor/aperture")
	collapse_register("frame_editor/light_management", true)
	collapse_register("frame_editor/color_correction", true)
	
	collapse_register("frame_editor/material_color")
	collapse_register("frame_editor/material_surface")
	collapse_register("frame_editor/material_subsurface")
	
	collapse_register("frame_editor/text_outline")
	collapse_register("frame_editor/text_alignment")

	collapse_register("library/text_outline")
	
	collapse_register("timeline_editor/inherit")
	collapse_register("timeline_editor/glint", true)
	collapse_register("timeline_editor/glow", true)
	collapse_register("timeline_editor/mode_visibility")
}
