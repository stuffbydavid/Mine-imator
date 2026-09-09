/// shader_high_indirect_source
/// Pre-calculates lighting for indirect resolve (instead of multiplying these look-ups by kernel count)

#pragma shady: inline(common_screen.VSH_FULLSCREEN_TEMPLATE)