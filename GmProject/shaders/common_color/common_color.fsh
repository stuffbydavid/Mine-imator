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

#region VIBRANCE_LIB
#pragma shady: macro_begin VIBRANCE_LIB

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

vec3 applyVibrance(vec3 color, float amount)
{
	vec3 intensity = vec3(dot(color, vec3(0.2125, 0.7154, 0.0721)));
	float saturation = rgbtohsb(vec4(color, 1.0)).g;
	float vibrance = 1.0 - pow(pow(saturation, 8.0), 0.15);
	return max(mix(intensity, color, 1.0 + vibrance * amount), vec3(0.0));
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

void applyColorTransformMixAlpha(inout vec4 col, bool preserveAlpha, float mixColorAlpha)
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
	applyColorTransformMixAlpha(col, preserveAlpha, uMixColor.a);
}

#pragma shady: macro_end
#endregion

#region TONEMAP_LIB
#pragma shady: macro_begin TONEMAP_LIB

/// ACES fit by Stephen Hill, via TheRealMJP/BakingLab (MIT)
/// https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl
vec3 RRTAndODTFit(vec3 v)
{
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return a / b;
}

vec3 mapACES(vec3 color)
{
	// Linear sRGB primaries => XYZ => D65_2_D60 => AP1 => RRT_SAT
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

vec3 mapReinhard(vec3 color)
{
	color = max(color, vec3(0.0));
	float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float mappedLuminance = luminance / (1.0 + luminance);
	return luminance > 0.0 ? color * mappedLuminance / luminance : vec3(0.0);
}

// Uchimura / Gran Turismo curve with the commonly published SDR parameters
// GLSL adaptation based on https://github.com/yaoling1997/GT-ToneMapping (MIT)
vec3 mapUchimura(vec3 color)
{
	color = max(color, vec3(0.0));
	float maximum = 1.0;
	float contrast = 1.0;
	float linearStart = 0.22;
	float linearLength = 0.4;
	float blackTightness = 1.33;
	float blackOffset = 0.0;
	float linearLength0 = (maximum - linearStart) * linearLength / contrast;
	float linearStart1 = linearStart + linearLength0;
	float shoulderStart = linearStart + contrast * linearLength0;
	float shoulderStrength = contrast * maximum / (maximum - shoulderStart);
	float shoulderExponent = -shoulderStrength / maximum;

	vec3 toe = linearStart * pow(color / linearStart, vec3(blackTightness)) + blackOffset;
	vec3 linearColor = linearStart + contrast * (color - linearStart);
	vec3 shoulder = maximum - (maximum - shoulderStart) * exp(shoulderExponent * (color - linearStart1));
	vec3 toeWeight = vec3(1.0) - smoothstep(vec3(0.0), vec3(linearStart), color);
	vec3 shoulderWeight = step(vec3(linearStart1), color);
	vec3 linearWeight = vec3(1.0) - toeWeight - shoulderWeight;
	return toe * toeWeight + linearColor * linearWeight + shoulder * shoulderWeight;
}

// Timothy Lottes' published SDR curve, independently expressed from its equation
// https://gpuopen.com/wp-content/uploads/2016/03/GdcVdrLottes.pdf
vec3 mapLottes(vec3 color)
{
	color = max(color, vec3(0.0));
	float contrast = 1.6;
	float shoulder = 0.977;
	float hdrMaximum = 8.0;
	float middleIn = 0.18;
	float middleOut = 0.267;
	float hdrPow = pow(hdrMaximum, contrast);
	float middlePow = pow(middleIn, contrast);
	float hdrShoulderPow = pow(hdrMaximum, contrast * shoulder);
	float middleShoulderPow = pow(middleIn, contrast * shoulder);
	float b = (-middlePow + hdrPow * middleOut) / ((hdrShoulderPow - middleShoulderPow) * middleOut);
	float c = (hdrShoulderPow * middlePow - hdrPow * middleShoulderPow * middleOut) / ((hdrShoulderPow - middleShoulderPow) * middleOut);
	return pow(color, vec3(contrast)) / (pow(color, vec3(contrast * shoulder)) * b + c);
}

// John Hable's Uncharted 2 curve, via tizian/tonemapper (MIT)
// https://github.com/tizian/tonemapper
vec3 hablePartial(vec3 color)
{
	float shoulderStrength = 0.15;
	float linearStrength = 0.5;
	float linearAngle = 0.1;
	float toeStrength = 0.2;
	float toeNumerator = 0.02;
	float toeDenominator = 0.3;
	return ((color * (shoulderStrength * color + linearAngle * linearStrength) + toeStrength * toeNumerator) /
		(color * (shoulderStrength * color + linearStrength) + toeStrength * toeDenominator)) - toeNumerator / toeDenominator;
}

vec3 mapHable(vec3 color)
{
	color = max(color, vec3(0.0));
	float exposureBias = 2.0;
	float whitePoint = 11.2;
	return hablePartial(color * exposureBias) / hablePartial(vec3(whitePoint));
}

// Polyphony Digital's GT7 SDR curve parameters (MIT)
// This is the analytical curve only, without the full ICtCp color-volume stage
// https://github.com/google/filament/blob/main/filament/src/ToneMapper.cpp
float gt7Curve(float value)
{
	value = max(value, 0.0);
	float peakIntensity = 2.5;
	float alpha = 0.25;
	float middlePoint = 0.538;
	float linearSection = 0.444;
	float toeStrength = 1.280;
	float k = (linearSection - 1.0) / (alpha - 1.0);
	float shoulderA = peakIntensity * linearSection + peakIntensity * k;
	float shoulderB = -peakIntensity * k * exp(linearSection / k);
	float shoulderC = -1.0 / (k * peakIntensity);
	float linearWeight = smoothstep(0.0, middlePoint, value);
	float toe = middlePoint * pow(value / middlePoint, toeStrength);
	float linearToe = mix(toe, value, linearWeight);
	float shoulder = shoulderA + shoulderB * exp(value * shoulderC);
	return value < linearSection * peakIntensity ? linearToe : shoulder;
}

vec3 mapGT7Curve(vec3 color)
{
	vec3 mapped = vec3(gt7Curve(color.r), gt7Curve(color.g), gt7Curve(color.b));
	return 0.4 * min(mapped, vec3(2.5));
}

vec3 applyToneMapper(vec3 col, int tonemapperId, float exposure, float gamma)
{
	// Exposure
	col *= exposure;

	if (tonemapperId == 1) // Reinhard
		col = mapReinhard(col);
	else if (tonemapperId == 2) // ACES
		col = mapACES(col);
	else if (tonemapperId == 3) // Uchimura
		col = mapUchimura(col);
	else if (tonemapperId == 4) // Lottes
		col = mapLottes(col);
	else if (tonemapperId == 5) // Hable
		col = mapHable(col);
	else if (tonemapperId == 6) // Gran Turismo 7 curve
		col = mapGT7Curve(col);

	// Gamma
	return pow(max(col.rgb, vec3(0.0)), vec3(1.0/gamma));
}

#pragma shady: macro_end
#endregion

#region RADIANCE_LIB
#pragma shady: macro_begin RADIANCE_LIB

vec3 compressRadiance(vec3 col)
{
	float lum = dot(max(col, vec3(0.0)), vec3(0.2126, 0.7152, 0.0722));
	return col / (1.0 + lum);
}

vec3 expandRadiance(vec3 col)
{
	float lum = dot(max(col, vec3(0.0)), vec3(0.2126, 0.7152, 0.0722));
	return col / max(1.0 - lum, 0.001);
}

#pragma shady: macro_end
#endregion
