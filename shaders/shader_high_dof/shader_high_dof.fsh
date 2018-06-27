uniform sampler2D uDepthBuffer;
uniform vec2 uScreenSize;
uniform float uBlurSize;
uniform float uDepth;
uniform float uRange;
uniform float uFadeSize;
uniform float uNear;
uniform float uFar;
uniform int uSamples;
uniform int uRingDetail;

varying vec2 vTexCoord;

const float pi = 3.14159265;
const float tau = pi * 2.0;
int totalSamples = uSamples * uRingDetail; // samples * ringDetail

float screenSampleSize = uScreenSize.y * uBlurSize;
vec2 texelSize = 1.0 / uScreenSize;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

float getDepth(vec2 coord)
{
	return uNear+ unpackDepth(texture2D(uDepthBuffer, coord)) * (uFar - uNear);
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

void main()
{
	float myDepth = getDepth(vTexCoord);
	float myFrontBlur = getFrontBlur(myDepth);
	float myBackBlur = getBackBlur(myDepth);
	
	float blur = 0.0;
	float maxdis = screenSampleSize * screenSampleSize + screenSampleSize * screenSampleSize;
	float colorDiv = 0.0;
	vec4 colorAdd = vec4(0.0);
	
	gl_FragColor = texture2D(gm_BaseTexture, vTexCoord);
	
	for (int i = 0; i < totalSamples; i++)
	{
		float angle = (float(i / uRingDetail) / float(uSamples)) * tau;
		float dis = 1.0 - mod(float(i),float(uRingDetail)) / float(uRingDetail);
		dis *= (myFrontBlur + myBackBlur);
		vec2 offset = vec2(cos(angle), sin(angle)) * dis * screenSampleSize;
		vec2 tex = vTexCoord + texelSize * offset;
		float sampleDepth = getDepth(tex);
		float sampleBlur = getBlur(sampleDepth);
		
		
		float mul = (1.0 - (1.0 - sampleBlur) * myBackBlur);
		
		if (mul > 0.0)
		{
			colorAdd += texture2D(gm_BaseTexture, tex) * mul;
			colorDiv += mul;
		}
		
		blur += getFrontBlur(sampleDepth);
	}
	
	blur /= float(totalSamples);
	blur += myFrontBlur + myBackBlur;
	
	colorAdd *= blur;
	colorDiv *= blur;
	
	gl_FragColor += colorAdd;
	gl_FragColor /= colorDiv + 1.0;
}
