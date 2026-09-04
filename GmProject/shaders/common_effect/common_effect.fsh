#pragma shady: skip_compilation
void main(){}

#region EFFECT_GLINT_LIB
#pragma shady: macro_begin EFFECT_GLINT_LIB

uniform sampler2D uGlintTexture; // static
uniform vec2 uGlintOffset;
uniform vec2 uGlintSize;
uniform int uGlintEnabled;
uniform float uGlintStrength;

vec3 getGlint(vec4 col, vec2 texCoord, vec2 texSize, float gamma)
{
	if (uGlintEnabled > 0 && col.a > 0.0)
		return pow(texture2D(uGlintTexture, (texCoord * ((texSize / uGlintSize))) + uGlintOffset).rgb * col.a * uGlintStrength, vec3(gamma));
	else
		return vec3(0.0);
}

#pragma shady: macro_end
#endregion

#region RADIAL_DISTORT_LIB
#pragma shady: macro_begin RADIAL_DISTORT_LIB

vec2 distortUv(vec2 coord, float amount)
{
	float d = dot(coord, coord);
	float distortion = amount * -0.25;
	coord *= 1.0 + distortion * d + distortion * d * d;
	return coord;
}

#pragma shady: macro_end
#endregion

#region EFFECT_CHROMATIC_ABERRATION_LIB
#pragma shady: macro_begin EFFECT_CHROMATIC_ABERRATION_LIB

#pragma shady: inline(common_effect.RADIAL_DISTORT_LIB)

uniform float uBlurAmount;
uniform vec3 uColorOffset;
uniform int uDistortChannels;

vec4 applyChromaticAberration(vec2 texCoord)
{
	int quality = 32;
	vec3 color = vec3(0.0);
	vec3 offset = uColorOffset;
	vec3 offsetStart = offset;

	for (int i = 0; i < quality; i++)
	{
		vec2 uv = (texCoord - 0.5) * 2.0;

		// Distort or scale RGB channels?
		vec2 uvRed, uvGreen, uvBlue;

		if (uDistortChannels > 0)
		{
			uvRed = distortUv(uv, offset.x);
			uvGreen = distortUv(uv, offset.y);
			uvBlue = distortUv(uv, offset.z);
		}
		else
		{
			uvRed = uv * (1.0 - offset.x * .25);
			uvGreen = uv * (1.0 - offset.y * .25);
			uvBlue = uv * (1.0 - offset.z * .25);
		}

		// Transform UV to 0 -> 1
		uvRed = (uvRed * 0.5) + 0.5;
		uvGreen = (uvGreen * 0.5) + 0.5;
		uvBlue = (uvBlue * 0.5) + 0.5;

		color.r += texture2D(gm_BaseTexture, uvRed).r;
		color.g += texture2D(gm_BaseTexture, uvGreen).g;
		color.b += texture2D(gm_BaseTexture, uvBlue).b;
		offset = mix(offsetStart, offsetStart + uBlurAmount, float(i) / float(quality));
	}

	return vec4(color / float(quality), texture2D(gm_BaseTexture, texCoord).a);
}

#pragma shady: macro_end
#endregion

#region EFFECT_COLOR_CORRECTION_LIB
#pragma shady: macro_begin EFFECT_COLOR_CORRECTION_LIB

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

uniform float uContrast;
uniform float uBrightness;
uniform float uSaturation;
uniform float uVibrance;
uniform vec4 uColorBurn;

vec4 applyColorCorrection(vec4 color)
{
	// Brightness and contrast
	color.rgb = (color.rgb - vec3(0.5)) * vec3(uContrast) + vec3(uBrightness + 0.5);
	color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));

	// Saturation
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(color.rgb, W));
	color.rgb = mix(satIntensity, color.rgb, uSaturation);
	color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));

	// Vibrance(Saturates desaturated colors)
	satIntensity = vec3(dot(color.rgb, W));
	float sat = rgbtohsb(color).g;
	float vibrance = 1.0 - pow(pow(sat, 8.0), .15);
	color.rgb = mix(satIntensity, color.rgb, 1.0 + (vibrance * uVibrance));
	color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));

	// Color burn
	color.rgb = 1.0 - (1.0 - color.rgb) / uColorBurn.rgb;

	return color;
}

#pragma shady: macro_end
#endregion

#region EFFECT_DISTORT_LIB
#pragma shady: macro_begin EFFECT_DISTORT_LIB

#pragma shady: inline(common_effect.RADIAL_DISTORT_LIB)

uniform float uDistortAmount;
uniform int uRepeatImage;
uniform float uZoomAmount;

vec4 applyDistortion(vec2 texCoord)
{
	// Transform UV to -1 -> 1
	vec2 uv = (texCoord - 0.5) * 2.0;
	uv /= uZoomAmount;

	uv = distortUv(uv, uDistortAmount);
	uv = (uv * 0.5) + 0.5;

	vec4 color = texture2D(gm_BaseTexture, uv);

	if (uRepeatImage < 1)
	{
		if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
			color = vec4(0.0);
	}

	return color;
}

#pragma shady: macro_end
#endregion

#region EFFECT_NOISE_LIB
#pragma shady: macro_begin EFFECT_NOISE_LIB

uniform sampler2D uNoiseBuffer;

uniform float uTime;
uniform float uStrength;
uniform float uSaturation;
uniform vec2 uSize;

uniform vec2 uScreenSize;

vec4 applyNoise(vec4 color, vec2 texCoord)
{
	vec2 coords = texCoord * (uScreenSize / uSize);
	vec4 noiseColor = texture2D(uNoiseBuffer, coords);

	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(noiseColor.rgb, W));
	noiseColor.rgb = mix(satIntensity, noiseColor.rgb, uSaturation);

	color.rgb += noiseColor.rgb * uStrength;
	return color;
}

#pragma shady: macro_end
#endregion

#region EFFECT_VIGNETTE_LIB
#pragma shady: macro_begin EFFECT_VIGNETTE_LIB

uniform vec2 uScreenSize;
uniform float uRadius;
uniform float uSoftness;
uniform float uStrength;

uniform vec4 uColor;

vec4 applyVignette(vec4 color, vec2 texCoord)
{
	vec2 centerCoord = texCoord - vec2(0.5);
	float len = length(centerCoord);
	float amount = smoothstep(uRadius, uRadius - clamp(uSoftness, 0.005, 1.0), len);

	color.rgb = mix(color.rgb, mix(uColor.rgb, color.rgb, amount), uStrength);
	return color;
}

#pragma shady: macro_end
#endregion

#region EFFECT_FOG_LIB
#pragma shady: macro_begin EFFECT_FOG_LIB

uniform int uFogShow;
uniform vec4 uFogColor; // static
uniform float uFogDistance; // static
uniform float uFogSize; // static
uniform float uFogHeight; // static

float getFog(vec3 pos, vec3 camPos)
{
	float fog;
	if (uFogShow > 0)
	{
		float fogDepth = distance(pos, camPos);

		fog = clamp(1.0 - (uFogDistance - fogDepth) / uFogSize, 0.0, 1.0);
		fog *= clamp(1.0 - (pos.z - uFogHeight) / uFogSize, 0.0, 1.0);
		fog = 1.0 - pow(1.0 - fog, 2.0); // Quadratic transition
	}
	else
		fog = 0.0;

	return fog;
}

#pragma shady: macro_end
#endregion
