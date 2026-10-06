/// CppOnly #define CPP_SUN_GBUFFERS 1

#pragma shady: inline(common_gbuffers.GBUFFERS_LIB)
#if CPP_SUN_GBUFFERS
	#pragma shady: inline(common_sun.SUN_LIB)
#endif

void main()
{
	vec4 baseColor, depth, normal, material, glint;
	vec3 normalWorld;
	float roughness, metallic, F0, sss;
	
	#if CPP_SUN_GBUFFERS
		vec2 gradient0 = getPCSSReceiverDepthGradient(vScreenCoord0.xy, vScreenCoord0.z);
		vec2 gradient1 = getPCSSReceiverDepthGradient(vScreenCoord1.xy, vScreenCoord1.z);
		vec2 gradient2 = getPCSSReceiverDepthGradient(vScreenCoord2.xy, vScreenCoord2.z);
	#endif
	
	getGbuffers(baseColor, normalWorld, roughness, metallic, F0, sss, depth, normal, material, glint);
	
	gl_FragData[0] = depth;
	gl_FragData[1] = normal;
	gl_FragData[2] = material;
	gl_FragData[3] = glint;
	
	#if CPP_SUN_GBUFFERS
		vec3 light, spec;
		getSunLighting(baseColor, normalWorld, roughness, metallic, F0, sss, gradient0, gradient1, gradient2, light, spec);
		
		if (uGlintPass > 0)
		{
			gl_FragData[4] = vec4(light, baseColor.a);
			gl_FragData[5] = vec4(spec, baseColor.a);
		}
		else
		{
			gl_FragData[3] = vec4(light, baseColor.a);
			gl_FragData[4] = vec4(spec, baseColor.a);
			gl_FragData[5] = vec4(0.0);
		}
	#endif
}
