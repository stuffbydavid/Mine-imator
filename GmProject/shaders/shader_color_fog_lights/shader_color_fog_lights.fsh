uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform int uColorsExt;
uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

uniform int uFogShow;
uniform vec4 uFogColor; // static
uniform float uFogDistance; // static
uniform float uFogSize; // static
uniform float uFogHeight; // static

uniform vec4 uFallbackColor;
uniform vec4 uAmbientColor;

uniform vec3 uCameraPosition; // static

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_effect.EFFECT_GLINT_LIB)
#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

float getFog()
{
	float fog;
	if (uFogShow > 0)
	{
		float fogDepth = distance(vPosition, uCameraPosition);
		
		fog = clamp(1.0 - (uFogDistance - fogDepth) / uFogSize, 0.0, 1.0);
		fog *= clamp(1.0 - (vPosition.z - uFogHeight) / uFogSize, 0.0, 1.0);
	}
	else
		fog = 0.0;
	
	return fog;
}

/// ACES (implementation by Stephen Hill, @self_shadow)
vec3 RRTAndODTFit(vec3 v)
{
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return a / b;
}

vec3 mapACES(vec3 color)
{
	// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
	color = vec3(
		color.r * 0.59719 + color.g * 0.35458 + color.b * 0.04823,
		color.r * 0.07600 + color.g * 0.90834 + color.b * 0.01566,
		color.r * 0.02840 + color.g * 0.13383 + color.b * 0.83777
	);
	
	color = RRTAndODTFit(color);
	
	// ODT_SAT => XYZ => D60_2_D65 => sRGB
	color = vec3(
		color.r *  1.60475 + color.g * -0.53108 + color.b * -0.07367,
		color.r * -0.10208 + color.g *  1.10813 + color.b * -0.00605,
		color.r * -0.00327 + color.g * -0.07276 + color.b *  1.07602
	);
	
	return color;
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	// Fresnel
	float F = getFresnel(vNormal, F0, roughness, uCameraPosition, vPosition);
	
	// Diffuse
	vec3 dif;
	
	// Assume no shading
	if (vDiffuse.r < 0.0)
	{
		dif = vec3(1.0);
		F = 0.0;
	}
	else
		dif = vDiffuse + uAmbientColor.rgb;
	
	dif *= (1.0 - F);
	dif = max(vec3(0.0), dif);
	
	vec4 col;
	vec3 spec;
	
	if (uColorsExt > 0)
	{
		col = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
		col = hsbtorgb(clamp(rgbtohsb(col) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
		col = mix(col, uMixColor, uMixColor.a); // Mix
	}
	else
		col = baseColor;
	
	if (vDiffuse.r >= 0.0)
		col.rgb = pow(col.rgb, vec3(uGamma));
	
	// Get specular color
	spec = (mix(vec3(1.0), col.rgb, metallic) * pow(uFallbackColor.rgb, vec3(uGamma)) * F);
	dif *= (1.0 - metallic);
	
	// Emissive
	dif += emissive;
	
	col.rgb *= dif; // Multiply diffuse
	col.rgb += spec; // Add specular
	col.rgb += getGlint(col, tex, uTextureSize, uGamma); // Add glint
	
	if (vDiffuse.r >= 0.0)
	{
		col.rgb *= uExposure;
		
		// Tone map
		if (uTonemapper == 1)
			col.rgb /= (1.0 + col.rgb); // Reinhard
		else if (uTonemapper == 2)
			col.rgb = mapACES(col.rgb); // ACES
		
		col.rgb = pow(col.rgb, vec3(1.0/uGamma));
	}
	
	col = mix(col, uFogColor, getFog()); // Mix fog
	col.a = mix(baseColor.a, 1.0, F); // Correct alpha
	
	handleAlphaDiscard(vPosition, col);
	
	gl_FragColor = col;
}
