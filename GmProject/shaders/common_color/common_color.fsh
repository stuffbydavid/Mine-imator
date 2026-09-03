#pragma shady: skip_compilation
void main(){}

#region COLOR_TRANSFORM_LIB
#pragma shady: macro_begin COLOR_TRANSFORM_LIB

vec4 rgbtohsb(vec4 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, c.a);
}

vec4 hsbtorgb(vec4 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return vec4(c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), c.a);
}

#pragma shady: macro_end
#endregion

#region COLOR_ADJUST_LIB
#pragma shady: macro_begin COLOR_ADJUST_LIB

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

void applyColorTransform(inout vec4 col, bool preserveAlpha, float mixColorAlpha)
{
	float alpha = col.a;
	col = clamp(col + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
	col = hsbtorgb(clamp(rgbtohsb(col) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
	col = mix(col, vec4(uMixColor.rgb, mixColorAlpha), uMixColor.a); // Mix
	if (preserveAlpha)
		col.a = alpha;
}

void applyColorTransform(inout vec4 col, bool preserveAlpha)
{
	applyColorTransform(col, preserveAlpha, uMixColor.a);
}

#pragma shady: macro_end
#endregion

#region TONEMAP_LIB
#pragma shady: macro_begin TONEMAP_LIB

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

vec3 applyToneMapper(vec3 col, int tonemapperId, float exposure, float gamma)
{
	// Exposure
	col *= exposure;

	if (tonemapperId == 1) // Reinhard
		col /= (1.0 + col);
	else if (tonemapperId == 2) // ACES
		col = mapACES(col);

	// Gamma
	return pow(col.rgb, vec3(1.0/gamma));
}

#pragma shady: macro_end
#endregion
