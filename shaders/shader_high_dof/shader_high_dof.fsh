uniform sampler2D uDepthBuffer;
uniform vec2 uScreenSize;
uniform vec2 uBlurSize;
uniform float uDepth;
uniform float uRange;
uniform float uFadeSize;
uniform float uNear;
uniform float uFar;

uniform float uBias;
uniform float uThreshold;
uniform float uGain;

uniform int uFringe;
uniform vec3 uFringeAngle;
uniform vec3 uFringeStrength;

varying vec2 vTexCoord;

const float pi = 3.14159265;
const float tau = pi * 2.0;

const int samplesMultiplier = 5;
const int rings = 8;

vec2 screenSampleSize = uScreenSize.y * uBlurSize;
vec2 texelSize = 1.0 / uScreenSize;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

float getDepth(vec2 coord)
{
	return uNear + unpackDepth(texture2D(uDepthBuffer, coord)) * (uFar - uNear);
}

float getBlur(float d)
{
	return clamp((abs(d - uDepth) - uRange) / uFadeSize, 0.0, 1.0);
}

float getFrontBlur(float d)
{
	return clamp(((uDepth - uRange) - d) / uFadeSize, 0.0, 1.0);
}

float getBackBlur(float d)
{
	return clamp((d - (uDepth + uRange)) / uFadeSize, 0.0, 1.0);
}

vec4 getFringe(vec2 coord, float blur, vec4 color)
{
	vec4 baseColor = color;
	
	if (uFringe < 1)
		return baseColor;
	
	vec2 fringeSize = texelSize.x * blur * screenSampleSize;
	
	vec2 redOffset = vec2(cos(uFringeAngle.x), sin(uFringeAngle.x)) * (uFringeStrength.x * fringeSize);
	float redDepth = getDepth(coord + redOffset);
	float redBlur = getBlur(redDepth);
	baseColor.r = texture2D(gm_BaseTexture, coord + redOffset * redBlur).r;
	
	vec2 greenOffset = vec2(cos(uFringeAngle.y), sin(uFringeAngle.y)) * (uFringeStrength.y * fringeSize);
	float greenDepth = getDepth(coord + greenOffset);
	float greenBlur = getBlur(greenDepth);
	baseColor.g = texture2D(gm_BaseTexture, coord + greenOffset * greenBlur).g;
	
	vec2 blueOffset = vec2(cos(uFringeAngle.z), sin(uFringeAngle.z)) * (uFringeStrength.z * fringeSize);
	float blueDepth = getDepth(coord + blueOffset);
	float blueBlur = getBlur(blueDepth);
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
	float myDepth = getDepth(vTexCoord);
	float myFrontBlur = getFrontBlur(myDepth);
	float myBackBlur = getBackBlur(myDepth);
	
	float blur = 0.0;
	vec2 maxdis = screenSampleSize * screenSampleSize + screenSampleSize * screenSampleSize;
	float colorDiv = 0.0;
	vec4 colorAdd = vec4(0.0);
	
	float weightStrength = 0.0;
	int ringSamples;

	gl_FragColor = texture2D(gm_BaseTexture, vTexCoord);
	
	for (int i = 1; i < rings; i++)
	{
		ringSamples = i * samplesMultiplier;
		
		for (int j = 0; j < ringSamples; j++)
		{
			float angleStep = tau / float(ringSamples);
			float dis = float(i) / float(samplesMultiplier);
			dis *= myFrontBlur + myBackBlur;
			vec2 offset = vec2(cos(float(j) * angleStep), sin(float(j) * angleStep)) * dis * screenSampleSize;
			vec2 tex = vTexCoord + texelSize * offset;
			float sampleDepth = getDepth(tex);
			float sampleBlur = getBlur(sampleDepth);
			
			float bias = mix(1.0, float(i) / float(samplesMultiplier), uBias);
			float mul = (1.0 - (1.0 - sampleBlur) * myBackBlur) * bias;	
			
			blur += getFrontBlur(sampleDepth);
			if (mul > 0.0)
			{
				colorAdd += getColor(tex, sampleBlur) * mul;
				colorDiv += mul;
			}
			
			weightStrength += bias; 
		}
	}
	
	blur /= weightStrength;
	blur += myFrontBlur + myBackBlur;
	
	colorAdd *= blur;
	colorDiv *= blur;
	
	gl_FragColor += colorAdd;
	gl_FragColor /= colorDiv + 1.0;
}
