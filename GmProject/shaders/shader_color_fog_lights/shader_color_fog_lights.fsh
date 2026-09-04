uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform int uColorsExt;

uniform vec4 uFallbackColor;
uniform vec4 uAmbientColor;

uniform vec3 uCameraPosition; // static

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_effect.EFFECT_GLINT_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_color.TONEMAP_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	bool isSky = vDiffuse.r < 0.0;
	
	if (baseColor.a == 0.0)
		discard;
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	float F = 0.0;
	vec3 dif = vec3(1.0);
	
	if (!isSky)
	{
		dif = vDiffuse + uAmbientColor.rgb;
		F = getFresnel(vNormal, F0, roughness, uCameraPosition, vPosition);
	
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
	
	col = mix(col, uFogColor, fog); // Mix fog
	col.a = mix(baseColor.a, 1.0, F); // Correct alpha
	col.a = mix(col.a, 1.0, fog);
	
	handleAlphaDiscard(vPosition, col);
	
	gl_FragColor = col;
}
