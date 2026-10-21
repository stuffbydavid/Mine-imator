uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform int uColorsExt;

uniform vec4 uFallbackColor;
uniform vec4 uAmbientColor;

uniform vec3 uCameraPosition; // static

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;
uniform float uNear; // static
uniform float uFar; // static
uniform int uIsGround;
uniform int uLightAmount; // static
uniform vec4 uLightData[128]; // static
uniform vec3 uLightAreaDirections[64]; // static
uniform vec3 uLightAreaU[64]; // static
uniform vec3 uLightAreaV[64]; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;
varying float vPlaceDistance;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.AREA_LIGHT_LIB)
#pragma shady: inline(common_effect.EFFECT_GLINT_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_color.TONEMAP_LIB)
#pragma shady: inline(common_place.PLACE_LIB)

void main()
{
	gl_FragData[0] = vec4(0.0);
	gl_FragData[1] = vec4(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	if (uRenderPlace > 0)
	{
		// Ignore transparent texels on non-block objects
		if (uPlaceType == PLACE_TYPE_SCENE && baseColor.a < 0.05)
			discard;
		
		gl_FragData[1] = getPlaceOutput(vPlaceDistance, uNear, uFar);
	}
	
	bool isSky = vDiffuse.r < 0.0;
	
	if (baseColor.a == 0.0 && (uRenderPlace == 0 || uPlaceType != PLACE_TYPE_BLOCK))
		discard;
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	float F = 0.0;
	vec3 dif = vec3(1.0);
	
	if (!isSky)
	{
		dif = vDiffuse + uAmbientColor.rgb;
		int lights = uIsGround > 0 ? 1 : uLightAmount;
		for (int i = 1; i < 64; i++)
		{
			if (i >= lights)
				break;
			vec3 direction = uLightAreaDirections[i];
			if (dot(direction, direction) == 0.0)
				continue;
			vec4 data = uLightData[i * 2];
			vec3 delta = data.xyz - vPosition;
			float distance2 = dot(delta, delta);
			float att = max(0.0, 1.0 - sqrt(distance2) / max(data.w, 0.0001));
			float area = getRectangleArea(uLightAreaU[i], uLightAreaV[i]);
			float irradiance = getRectangleIrradiance(vPosition, normalize(vNormal), data.xyz, direction, uLightAreaU[i], uLightAreaV[i]);
			dif += uLightData[i * 2 + 1].rgb * irradiance * att * distance2 / max(area, 0.00000001);
		}
		F = getFresnel(vNormal, mix(F0, 1.0, metallic), roughness, uCameraPosition, vPosition);
	
		dif *= (1.0 - F);
		dif = max(vec3(0.0), dif);
	}
	
	vec4 col = baseColor;
	
	if (uColorsExt > 0)
		applyColorTransform(col, false);
	
	if (!isSky)
		col.rgb = pow(col.rgb, vec3(uGamma));
	
	// Get specular color
	vec3 spec = (mix(vec3(1.0), col.rgb, metallic) * pow(uFallbackColor.rgb, vec3(uGamma)) * F);
	dif *= (1.0 - metallic);
	
	col.rgb *= dif + emissive; // Multiply diffuse
	col.rgb += spec; // Add specular
	col.rgb += getGlint(col, tex, uTextureSize, uGamma); // Add glint
	
	if (!isSky)
		col.rgb = applyToneMapper(col.rgb, uTonemapper, uExposure, uGamma);
	
	float fog = getFog(vPosition, uCameraPosition);
	
	col.rgb = mix(col.rgb, uFogColor.rgb, fog); // Mix fog
	col.a = baseColor.a;
	
	if (uRenderPlace == 0 || uPlaceType == PLACE_TYPE_PLACED || uPlaceType == PLACE_TYPE_CLOUDS)
		handleAlphaDiscard(vPosition, col);
	
	gl_FragData[0] = col;
}
