/// CppOnly #define CPP_SUN_GBUFFERS 1

#ifdef CPP_SUN_GBUFFERS
	#pragma shady: inline(common_gbuffers.GBUFFERS_LIB)
	#pragma shady: inline(common_sun.SUN_LIB)
	#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
	#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

	uniform int uColorsExt;
	uniform vec4 uReplaceColor;
#endif

void main()
{
	#ifdef CPP_SUN_GBUFFERS
		vec4 baseColor, depth, normal, material, glint;
		vec3 normalWorld, light, spec;
		float roughness, metallic, F0, sss;
		
		getGbuffers(baseColor, normalWorld, roughness, metallic, F0, sss, depth, normal, material, glint);
		getSunLighting(baseColor, normalWorld, roughness, metallic, F0, sss, light, spec);
		
		gl_FragData[0] = baseColor;
		
		if (uColorsExt > 0)
			applyColorTransform(gl_FragData[0], true);
		
		gl_FragData[1] = vec4(uReplaceColor.rgb, baseColor.a);
		gl_FragData[2] = vec4(vec3(getFog(vPosition, uCameraPosition)), 1.0);
		gl_FragData[3] = depth;
		gl_FragData[4] = normal;
		gl_FragData[5] = material;
		gl_FragData[6] = vec4(light, baseColor.a);
		gl_FragData[7] = vec4(spec, baseColor.a);
	#endif
	
	#ifndef CPP_SUN_GBUFFERS
		gl_FragData[0] = vec4(0.0);
	#endif
}
