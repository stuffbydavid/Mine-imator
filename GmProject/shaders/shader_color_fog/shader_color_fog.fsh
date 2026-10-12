uniform sampler2D uTexture; // static

uniform int uColorsExt;
uniform vec4 uReplaceColor;
uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

uniform vec3 uCameraPosition; // static
uniform int uFogPass; // static
uniform float uNear; // static
uniform float uFar; // static

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vPlaceDistance;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_color.TONEMAP_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)
#pragma shady: inline(common_place.PLACE_LIB)

void main()
{
	vec2 tex = vTexCoord;
	gl_FragData[0] = vColor * texture2D(uTexture, tex); // Get base
	gl_FragData[1] = vec4(0.0);
	
	if (uRenderPlace > 0)
	{
		// Ignore transparent texels on non-block objects
		if (uPlaceType == PLACE_TYPE_SCENE && gl_FragData[0].a < 0.05)
			discard;
		
		gl_FragData[1] = getPlaceOutput(vPlaceDistance, uNear, uFar);
	}
	
	if (uRenderPlace == 0 || uPlaceType == PLACE_TYPE_PLACED || uPlaceType == PLACE_TYPE_CLOUDS)
		handleAlphaDiscard(vPosition, gl_FragData[0]);
	
	if (uColorsExt > 0)
		applyColorTransform(gl_FragData[0], true);

	if (uTonemapper > 0)
		gl_FragData[0].rgb = applyToneMapper(gl_FragData[0].rgb, uTonemapper, uExposure, uGamma);
	
	float fog = getFog(vPosition, uCameraPosition);
	// Leave material lookup to the auxiliary pass when it will rebuild this target
	if (uFogPass > 0)
	{
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		gl_FragData[2] = vec4(fog, emissive * uReplaceColor.r, 0.0, gl_FragData[0].a);
	}
	else
		gl_FragData[2] = vec4(0.0);

	gl_FragData[0].rgb = mix(gl_FragData[0].rgb, uFogColor.rgb, fog); // Mix fog
	
	if (uRenderPlace == 0)
		gl_FragData[1] = vec4(gl_FragData[0].rgb * uReplaceColor.rgb, gl_FragData[0].a);
}
