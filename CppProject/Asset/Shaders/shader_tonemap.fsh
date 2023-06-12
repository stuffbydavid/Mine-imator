varying vec2 vTexCoord;

uniform sampler2D uMask;

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

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
	// Get base
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 color = baseColor;
	
	// Exposure
	color.rgb *= uExposure;
	
	// Tone map
	if (uTonemapper == 1)
		color.rgb /= (1.0 + color.rgb); // Reinhard
	else if (uTonemapper == 2)
		color.rgb = mapACES(color.rgb); // ACES
	
	// Gamma
	color.rgb = pow(color.rgb, vec3(1.0/uGamma));
	
	gl_FragColor = mix(baseColor, color, texture2D(uMask, vTexCoord).r);
}