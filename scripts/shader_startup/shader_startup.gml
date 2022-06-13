/// shader_startup()

function shader_startup()
{
	globalvar shader_map, shader_texture_surface, shader_texture_filter_linear, shader_texture_filter_mipmap, shader_check_uniform;
	globalvar shader_blend_color, shader_blend_alpha;
	globalvar shader_scissor_x, shader_scissor_y, shader_scissor_width, shader_scissor_height, shader_scissor_active;
	
	// Scissor
	shader_scissor_x = 0
	shader_scissor_y = 0
	shader_scissor_width = 0
	shader_scissor_height = 0
	shader_scissor_active = false
	
	// Texture drawing
	globalvar shader_mask;
	shader_mask = false
	
	// Init shaders
	log("Shader init")
	log("shaders_are_supported", yesno(shaders_are_supported()))
	
	var err = false;
	if (!shaders_are_supported())
		err = true
	
	shader_check_uniform = false
	
	// Compiled?
	if (!err)
	{
		shader_map = ds_map_create()
		new_shader("shader_alpha_fix")
		new_shader("shader_alpha_test")
		new_shader("shader_blend")
		new_shader("shader_border")
		new_shader("shader_color_camera")
		new_shader("shader_color_fog")
		new_shader("shader_color_fog_lights")
		new_shader("shader_depth")
		new_shader("shader_depth_ortho")
		new_shader("shader_depth_point")
		new_shader("shader_draw_texture")
		new_shader("shader_replace")
		new_shader("shader_replace_alpha")
		new_shader("shader_high_dof")
		new_shader("shader_high_dof_coc")
		new_shader("shader_high_dof_coc_blur")
		new_shader("shader_high_fog")
		new_shader("shader_high_fog_apply")
		new_shader("shader_high_light_apply")
		new_shader("shader_high_light_night")
		new_shader("shader_high_light_point")
		new_shader("shader_high_light_point_shadowless")
		new_shader("shader_high_light_spot")
		new_shader("shader_high_light_sun")
		new_shader("shader_high_ssao")
		new_shader("shader_high_ssao_blur")
		new_shader("shader_high_ssao_depth_normal")
		new_shader("shader_color_glow")
		new_shader("shader_high_bloom_threshold")
		new_shader("shader_add")
		new_shader("shader_blur")
		new_shader("shader_color_correction")
		new_shader("shader_vignette")
		new_shader("shader_noise")
		new_shader("shader_high_light_desaturate")
		new_shader("shader_ca")
		new_shader("shader_distort")
		new_shader("shader_high_lighting_apply")
		new_shader("shader_high_samples_add")
		new_shader("shader_high_samples_unpack")
		new_shader("shader_high_volumetric_fog")
		new_shader("shader_high_volumetric_fog_apply")
		new_shader("shader_high_raytrace_depth_normal")
		new_shader("shader_high_reflections_apply")
		new_shader("shader_high_material")
		new_shader("shader_high_subsurface")
		new_shader("shader_high_subsurface_scatter")
		new_shader("shader_high_raytrace_uv")
		new_shader("shader_high_raytrace_indirect")
		new_shader("shader_high_raytrace_reflections")
		new_shader("shader_high_indirect_blur")
		new_shader("shader_scissor")
		
		shader_texture_surface = false
		shader_texture_filter_linear = false
		shader_texture_filter_mipmap = false
		
		with (obj_shader)
		{
			log(name + " compiled", yesno(shader_is_compiled(shader)))
			
			if (!shader_is_compiled(shader))
			{
				err = true
				break
			}
		}
	}
	
	if (err)
	{
		log("Shader compilation failed")
		log("Try updating your graphics drivers", link_article_drivers)
		if (show_question("Some shaders failed to compile.\nCheck that your graphics drivers are up-to-date and restart Mine-imator.\n\nOpen support article about updating graphics drivers?"))
			open_url(link_article_drivers)
		
		game_end()
		return false
	}
	
	// Set special uniforms
	with (shader_map[?shader_border])
	{
		new_shader_uniform("uTexSize")
		new_shader_uniform("uColor")
	}
	
	with (shader_map[?shader_color_camera])
	{
		new_shader_uniform("uBrightness")
		new_shader_uniform("uRGBAdd")
		new_shader_uniform("uRGBSub")
		new_shader_uniform("uHSBAdd")
		new_shader_uniform("uHSBSub")
		new_shader_uniform("uHSBMul")
		new_shader_uniform("uMixColor")
	}
	
	with (shader_map[?shader_color_fog])
	{
		new_shader_uniform("uColorsExt")
		new_shader_uniform("uRGBAdd")
		new_shader_uniform("uRGBSub")
		new_shader_uniform("uHSBAdd")
		new_shader_uniform("uHSBSub")
		new_shader_uniform("uHSBMul")
		new_shader_uniform("uMixColor")
	}
	
	with (shader_map[?shader_color_fog_lights])
	{
		new_shader_uniform("uIsGround")
		new_shader_uniform("uIsSky")
		new_shader_uniform("uColorsExt")
		new_shader_uniform("uRGBAdd")
		new_shader_uniform("uRGBSub")
		new_shader_uniform("uHSBAdd")
		new_shader_uniform("uHSBSub")
		new_shader_uniform("uHSBMul")
		new_shader_uniform("uMixColor")
		new_shader_uniform("uLightAmount")
		new_shader_uniform("uSunDirection")
		new_shader_uniform("uLightData")
		new_shader_uniform("uAmbientColor")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uBlockSSS")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		new_shader_uniform("uFallbackColor")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
	}
	
	with (shader_map[?shader_depth])
	{
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
	}
	
	with (shader_map[?shader_depth_point])
	{
		new_shader_uniform("uEye")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
	}
	
	with (shader_map[?shader_draw_texture])
		new_shader_uniform("uMask")
	
	with (shader_map[?shader_replace])
		new_shader_uniform("uReplaceColor")
	
	with (shader_map[?shader_replace_alpha])
		new_shader_uniform("uReplaceColor")
	
	with (shader_map[?shader_high_dof])
	{
		new_shader_sampler("uBlurBuffer")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uBlurSize")
		new_shader_uniform("uBias")
		new_shader_uniform("uThreshold")
		new_shader_uniform("uGain")
		new_shader_uniform("uFringe")
		new_shader_uniform("uFringeAngle")
		new_shader_uniform("uFringeStrength")
		new_shader_uniform("uSampleAmount")
		new_shader_uniform("uSamples")
		new_shader_uniform("uWeightSamples")
	}
	
	with (shader_map[?shader_high_dof_coc])
	{
		new_shader_sampler("uDepthBuffer")
		new_shader_uniform("uDepth")
		new_shader_uniform("uRange")
		new_shader_uniform("uFadeSize")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
	}
	
	with (shader_map[?shader_high_dof_coc_blur])
	{
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uPixelCheck")
	}
	
	with (shader_map[?shader_high_fog])
	{
		new_shader_uniform("uCameraPos")
	}
	
	with (shader_map[?shader_high_fog_apply])
	{
		new_shader_sampler("uFogBuffer")
		new_shader_uniform("uFogColor")
	}
	
	with (shader_map[?shader_high_light_apply])
		new_shader_uniform("uAmbientColor")
	
	with (shader_map[?shader_high_light_desaturate])
	{
		new_shader_sampler("uShadowBuffer")
		new_shader_uniform("uAmount")
	}
	
	with (shader_map[?shader_high_light_night])
	{
		new_shader_uniform("uLightEnable")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
	}
	
	with (shader_map[?shader_high_light_point])
	{
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uBlockSSS")
		new_shader_uniform("uIsSky")
		new_shader_uniform("uIsWater")
		new_shader_uniform("uLightAmount")
		new_shader_uniform("uLightPosition")
		new_shader_uniform("uLightColor")
		new_shader_uniform("uLightStrength")
		new_shader_uniform("uLightNear")
		new_shader_uniform("uLightFar")
		new_shader_uniform("uLightFadeSize")
		new_shader_sampler("uDepthBuffer")
		new_shader_uniform("uDepthBufferSize")
		new_shader_uniform("uSSS")
		new_shader_uniform("uSSSRadius")
		new_shader_uniform("uSSSColor")
		new_shader_uniform("uShadowPosition")
		new_shader_uniform("uSpecularStrength")
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		new_shader_uniform("uLightSize")
	}
	
	with (shader_map[?shader_high_light_point_shadowless])
	{
		new_shader_uniform("uIsSky")
		new_shader_uniform("uLightAmount")
		new_shader_uniform("uLightData")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uBlockSSS")
		new_shader_uniform("uIsWater")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		new_shader_uniform("uSpecularStrength")
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
	}
	
	with (shader_map[?shader_high_light_spot])
	{
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uBlockSSS")
		new_shader_uniform("uIsSky")
		new_shader_uniform("uIsWater")
		new_shader_uniform("uLightAmount")
		new_shader_uniform("uLightMatrix")
		new_shader_uniform("uShadowMatrix")
		new_shader_uniform("uLightPosition")
		new_shader_uniform("uLightColor")
		new_shader_uniform("uLightStrength")
		new_shader_uniform("uLightNear")
		new_shader_uniform("uLightFar")
		new_shader_uniform("uLightFadeSize")
		new_shader_uniform("uLightSpotSharpness")
		new_shader_sampler("uDepthBuffer")
		new_shader_uniform("uSSS")
		new_shader_uniform("uSSSRadius")
		new_shader_uniform("uSSSColor")
		new_shader_uniform("uSpecularStrength")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		new_shader_uniform("uLightSize")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
	}
	
	with (shader_map[?shader_high_light_sun])
	{
		new_shader_uniform("uBrightness")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uBlockSSS")
		new_shader_uniform("uIsSky")
		new_shader_uniform("uIsWater")
		new_shader_uniform("uLightDirection")
		new_shader_uniform("uLightColor")
		new_shader_uniform("uLightStrength")
		new_shader_uniform("uSunNear")
		new_shader_uniform("uSunFar")
		new_shader_sampler("uDepthBuffer0")
		new_shader_sampler("uDepthBuffer1")
		new_shader_sampler("uDepthBuffer2")
		new_shader_uniform("uSSS")
		new_shader_uniform("uSSSRadius")
		new_shader_uniform("uSSSColor")
		new_shader_uniform("uSpecularStrength")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
		new_shader_uniform("uLightMatBiasMVP")
		new_shader_uniform("uCascadeEndClipSpace")
		new_shader_uniform("uCascadeDebug")
	}
	
	with (shader_map[?shader_high_ssao])
	{
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_sampler("uBrightnessBuffer")
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uProjMatrix")
		new_shader_uniform("uProjMatrixInv")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uKernel")
		new_shader_uniform("uRadius")
		new_shader_uniform("uPower")
		new_shader_uniform("uColor")
	}
	
	with (shader_map[?shader_high_ssao_blur])
	{
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uPixelCheck")
	}
	
	with (shader_map[?shader_high_ssao_depth_normal])
	{
		new_shader_uniform("uSSAOEnable")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
	}
	
	with (shader_map[?shader_color_glow])
	{
		new_shader_uniform("uColorsExt")
		new_shader_uniform("uRGBAdd")
		new_shader_uniform("uRGBSub")
		new_shader_uniform("uHSBAdd")
		new_shader_uniform("uHSBSub")
		new_shader_uniform("uHSBMul")
		new_shader_uniform("uMixColor")
		new_shader_uniform("uGlow")
		new_shader_uniform("uGlowTexture")
		new_shader_uniform("uGlowColor")
		new_shader_uniform("uBlockGlow")
		new_shader_uniform("uBlockBrightness")
		new_shader_uniform("uGlowThreshold")
	}
	
	with (shader_map[?shader_high_bloom_threshold])
	{
		new_shader_uniform("uThreshold")
	}
	
	with (shader_map[?shader_add])
	{
		new_shader_sampler("uAddTexture")
		new_shader_uniform("uAmount")
		new_shader_uniform("uPower")
	}
	
	with (shader_map[?shader_blur])
	{
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uRadius")
		new_shader_uniform("uDirection")
	}
	
	with (shader_map[?shader_color_correction])
	{
		new_shader_uniform("uContrast")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uSaturation")
		new_shader_uniform("uVibrance")
		new_shader_uniform("uColorBurn")
	}
	
	with (shader_map[?shader_vignette])
	{
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uRadius")
		new_shader_uniform("uSoftness")
		new_shader_uniform("uStrength")
		new_shader_uniform("uColor")
	}
	
	with (shader_map[?shader_noise])
	{
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uStrength")
		new_shader_uniform("uSaturation")
		new_shader_uniform("uSize")
		new_shader_uniform("uScreenSize")
	}
	
	with (shader_map[?shader_ca])
	{
		new_shader_uniform("uBlurAmount")
		new_shader_uniform("uColorOffset")
		new_shader_uniform("uDistortChannels")
	}
	
	with (shader_map[?shader_distort])
	{
		new_shader_uniform("uDistortAmount")
		new_shader_uniform("uRepeatImage")
	}
	
	with (shader_map[?shader_high_lighting_apply])
	{
		new_shader_sampler("uSSAO")
		new_shader_sampler("uShadows")
		new_shader_sampler("uSpecular")
		new_shader_sampler("uMask")
		new_shader_sampler("uIndirect")
		new_shader_sampler("uMaterialBuffer")
		new_shader_uniform("uSSAOEnabled")
		new_shader_uniform("uShadowsEnabled")
		new_shader_uniform("uAmbientColor")
		new_shader_uniform("uIndirectEnabled")
		new_shader_uniform("uIndirectStrength")
		new_shader_uniform("uReflectionsEnabled")
		new_shader_uniform("uFallbackColor")
		new_shader_uniform("uGammaCorrect")
	}
	
	with (shader_map[?shader_high_samples_add])
	{
		new_shader_sampler("uSamplesExp")
		new_shader_sampler("uSamplesDec")
		new_shader_sampler("uShadow")
	}
	
	with (shader_map[?shader_high_samples_unpack])
	{
		new_shader_sampler("uSamplesExp")
		new_shader_sampler("uSamplesDec")
		new_shader_uniform("uSamplesStrength")
	}
	
	with (shader_map[?shader_high_volumetric_fog])
	{
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uSunNear")
		new_shader_uniform("uSunFar")
		new_shader_uniform("uScattering")
		new_shader_uniform("uDensity")
		new_shader_uniform("uFogHeight")
		new_shader_uniform("uFogHeightFade")
		new_shader_uniform("uFogNoise")
		new_shader_uniform("uFogNoiseScale")
		new_shader_uniform("uFogNoiseContrast")
		new_shader_uniform("uFogAmbience")
		new_shader_uniform("uFogWind")
		new_shader_uniform("uViewMatrix")
		new_shader_uniform("uProjMatrix")
		new_shader_uniform("uViewMatrixInv")
		new_shader_uniform("uProjMatrixInv")
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uDepthBuffer0")
		new_shader_sampler("uDepthBuffer1")
		new_shader_sampler("uDepthBuffer2")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uSunDirection")
		new_shader_uniform("uSunVisible")
		new_shader_uniform("uLightMatBiasMVP")
		new_shader_uniform("uCascadeEndClipSpace")
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uColor")
		new_shader_uniform("uSunColor")
		new_shader_uniform("uAmbientColor")
		new_shader_uniform("uFogAmbience")
	}
	
	with (shader_map[?shader_high_volumetric_fog_apply])
	{
		new_shader_sampler("uSamplesExp")
		new_shader_sampler("uSamplesDec")
		new_shader_uniform("uSamplesStrength")
		new_shader_uniform("uColor")
		new_shader_uniform("uSunColor")
		new_shader_uniform("uAmbientColor")
		new_shader_uniform("uFogAmbience")
	}
	
	with (shader_map[?shader_high_raytrace_depth_normal])
	{
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uBrightness")
		new_shader_uniform("uIsWater")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
	}
	
	with (shader_map[?shader_high_reflections_apply])
	{
		new_shader_sampler("uReflectionsBuffer")
		new_shader_sampler("uMaterialBuffer")
		new_shader_sampler("uDiffuseBuffer")
	}
	
	with (shader_map[?shader_high_material])
	{
		new_shader_uniform("uMetallic")
		new_shader_uniform("uRoughness")
		new_shader_uniform("uIsWater")
		
		new_shader_sampler("uTextureMaterial")
		new_shader_uniform("uTexScaleMaterial")
		new_shader_uniform("uMaterialUseGlossiness")
		
		new_shader_sampler("uTextureNormal")
		new_shader_uniform("uTexScaleNormal")
	}
	
	with (shader_map[?shader_high_subsurface])
	{
		new_shader_uniform("uSSS")
		new_shader_uniform("uSSSRadius")
		new_shader_uniform("uSSSColor")
		new_shader_uniform("uBlockSSS")
	}
	
	with (shader_map[?shader_high_subsurface_scatter])
	{
		new_shader_sampler("uSSSBuffer")
		new_shader_sampler("uSSSRangeBuffer")
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uDirect")
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uSamples")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uKernel")
		new_shader_uniform("uProjMatrix")
		new_shader_uniform("uProjMatrixInv")
	}
	
	with (shader_map[?shader_high_raytrace_uv])
	{
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_sampler("uNormalBufferExp")
		new_shader_sampler("uMaterialBuffer")
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uProjMatrix")
		new_shader_uniform("uProjMatrixInv")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uPrecision")
		new_shader_uniform("uThickness")
		new_shader_uniform("uFallbackColor")
		new_shader_uniform("uFadeAmount")
		new_shader_uniform("uSpecularRay")
	}
	
	with (shader_map[?shader_high_raytrace_indirect])
	{
		new_shader_sampler("uRaytraceBuffer")
		new_shader_sampler("uRaytrace2Buffer")
		new_shader_sampler("uLightingBuffer")
		new_shader_sampler("uDiffuseBuffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_sampler("uNormalBufferExp")
		new_shader_sampler("uDepthBuffer")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uProjMatrixInv")
	}
	
	with (shader_map[?shader_high_raytrace_reflections])
	{
		new_shader_sampler("uRaytraceBuffer")
		new_shader_sampler("uRaytrace2Buffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_sampler("uNormalBufferExp")
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uDiffuseBuffer")
		new_shader_sampler("uMaterialBuffer")
		new_shader_uniform("uNear")
		new_shader_uniform("uFar")
		new_shader_uniform("uProjMatrixInv")
		new_shader_uniform("uFallbackColor")
		new_shader_uniform("uFadeAmount")
	}
	
	with (shader_map[?shader_high_indirect_blur])
	{
		new_shader_sampler("uDepthBuffer")
		new_shader_sampler("uNormalBuffer")
		new_shader_sampler("uNoiseBuffer")
		new_shader_uniform("uScreenSize")
		new_shader_uniform("uNoiseSize")
		new_shader_uniform("uSamples")
		new_shader_uniform("uBlurSize")
	}
	
	with (shader_map[?shader_scissor])
	{
		new_shader_uniform("uBox")
		new_shader_uniform("uScreenSize")
	}
	
	return true
}
