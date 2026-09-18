uniform sampler2D uBlurBuffer;
uniform sampler2D uNoiseBuffer;
uniform vec2 uScreenSize;
uniform float uBlurSize;
uniform float uNoiseSize;

uniform float uBias;
uniform float uThreshold;
uniform float uGain;

uniform int uFringe;
uniform vec2 uFringeOffsetRed;
uniform vec2 uFringeOffsetGreen;
uniform vec2 uFringeOffsetBlue;

uniform int uSampleAmount;
uniform vec2 uSamples[128];
uniform float uWeightSamples[128];
uniform float uAreaSamples[128];
uniform int uBladeAmount;
uniform float uBladeRotation;
uniform float uBlurRatio;
uniform float uBladeCurvature;
uniform float uBladeStretch;
uniform int uPixelRotation;

varying vec2 vTexCoord;

vec3 apertureSample(vec2 polar, float pixelAngle, vec2 cameraRotation, vec2 bladeGeometry)
{
	float angle = polar.y + pixelAngle;
	float edge = 1.0;

	if (uBladeAmount > 2)
	{
		float localAngle = mod(angle - 4.71238898038 + 6.28318530718, bladeGeometry.x) - bladeGeometry.x * 0.5;
		edge = mix(bladeGeometry.y / cos(localAngle), 1.0, uBladeCurvature);
	}

	vec2 point = vec2(cos(angle), sin(angle)) * (polar.x * edge);
	point *= vec2(1.0 - max(uBladeStretch, 0.0), 1.0 + min(uBladeStretch, 0.0));
	point = vec2(point.x * cameraRotation.x - point.y * cameraRotation.y,
	             point.x * cameraRotation.y + point.y * cameraRotation.x);
	point *= vec2(1.0 - max(uBlurRatio, 0.0), 1.0 + min(uBlurRatio, 0.0));
	return vec3(point, edge * edge);
}

float getBlur(vec2 coord)
{
	vec2 blur = texture2D(uBlurBuffer, coord).xy;
	return clamp(blur.x + blur.y, 0.0, 1.0);
}

vec4 getFringe(vec2 coord, float blur, vec4 color)
{
	vec4 baseColor = color;
	
	if (uFringe < 1)
		return baseColor;
	
	vec2 redOffset = uFringeOffsetRed * blur;
	float redBlur = getBlur(coord + redOffset);
	baseColor.r = texture2D(gm_BaseTexture, coord + redOffset * redBlur).r;
	
	vec2 greenOffset = uFringeOffsetGreen * blur;
	float greenBlur = getBlur(coord + greenOffset);
	baseColor.g = texture2D(gm_BaseTexture, coord + greenOffset * greenBlur).g;
	
	vec2 blueOffset = uFringeOffsetBlue * blur;
	float blueBlur = getBlur(coord + blueOffset);
	baseColor.b = texture2D(gm_BaseTexture, coord + blueOffset * blueBlur).b;
	
	return baseColor;
}

vec4 getColor(vec2 coord, float blur)
{
	vec4 baseColor = texture2D(gm_BaseTexture, coord);
	
	baseColor = getFringe(coord, blur, baseColor);
	
	// Boost brightness using threshold and gain strengthen Bokeh highlights
	vec3 lumCo = vec3(0.299,0.587,0.114);
	float lum = dot(baseColor.rgb, lumCo);
	float thresh = max((lum - uThreshold) * uGain, 0.0);
	baseColor.rgb = baseColor.rgb + mix(vec3(0.0), baseColor.rgb, vec3(thresh * blur));
	
	return baseColor;
}

void main()
{
	vec2 texelSize = 1.0 / uScreenSize;
	float screenSampleSize = uScreenSize.y * uBlurSize;
	vec2 blurTex = texture2D(uBlurBuffer, vTexCoord).rg;
	float blur = clamp(blurTex.r + blurTex.g, 0.0, 1.0);
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	if (blur > 0.0)
	{
		float pixelAngle = 0.0;
		float radialJitter = 0.5;
		vec2 cameraRotation = vec2(1.0, 0.0);
		vec2 bladeGeometry = vec2(1.0, 1.0);
		mat2 circleTransform = mat2(1.0);
		if (uPixelRotation > 0)
		{
			vec2 noise = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)).rg;
			pixelAngle = noise.r * 6.28318530718;
			radialJitter = noise.g;
			cameraRotation = vec2(cos(uBladeRotation), sin(uBladeRotation));
			if (uBladeAmount > 2)
			{
				bladeGeometry.x = 6.28318530718 / float(uBladeAmount);
				bladeGeometry.y = cos(bladeGeometry.x * 0.5);
			}
			else
			{
				float pc = cos(pixelAngle);
				float ps = sin(pixelAngle);
				mat2 pixelRotation = mat2(pc, ps, -ps, pc);
				mat2 bladeSqueeze = mat2(1.0 - max(uBladeStretch, 0.0), 0.0,
				                         0.0, 1.0 + min(uBladeStretch, 0.0));
				mat2 bladeRotation = mat2(cameraRotation.x, cameraRotation.y,
				                          -cameraRotation.y, cameraRotation.x);
				mat2 screenSqueeze = mat2(1.0 - max(uBlurRatio, 0.0), 0.0,
				                          0.0, 1.0 + min(uBlurRatio, 0.0));
				circleTransform = screenSqueeze * bladeRotation * bladeSqueeze * pixelRotation;
			}
		}

		vec4 color = vec4(0.0);
		float totalWeight = 0.0;

		for (int i = 0; i < 128; i++)
		{
			if (i >= uSampleAmount)
				break;
			
			vec3 aperture = vec3(uSamples[i], uAreaSamples[i]);
			float weightRadius = uWeightSamples[i];
			if (uPixelRotation > 0)
			{
				float radiusScale = sqrt((float(i) + radialJitter) / (float(i) + 0.5));
				weightRadius *= radiusScale;
				if (uBladeAmount > 2)
				{
					vec2 polar = uSamples[i];
					polar.x *= radiusScale;
					aperture = apertureSample(polar, pixelAngle, cameraRotation, bladeGeometry);
				}
				else
				{
					vec2 point = uSamples[i] * radiusScale;
					aperture = vec3(circleTransform * point, 1.0);
				}
			}
			
			// Add rim bias
			float rim = smoothstep(0.0, 1.0, weightRadius);
			float weight = (1.0 + max(uBias, 0.0) * rim) * aperture.z;
			vec2 tex = vTexCoord + texelSize * (aperture.xy * blur * screenSampleSize);
			float sampleBlur = getBlur(tex);
			float tapWeight = weight * (1.0 - (1.0 - sampleBlur) * blur);
			color += getColor(tex, sampleBlur) * tapWeight;
			totalWeight += tapWeight;
		}
		gl_FragColor = totalWeight > 0.0 ? color / totalWeight : baseColor;
	}
	else
		gl_FragColor = baseColor;
}
