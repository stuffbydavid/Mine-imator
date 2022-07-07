uniform sampler2D uSamplesExp;
uniform sampler2D uSamplesDec;
uniform sampler2D uSamplesAlpha;

uniform float uSamplesStrength;
uniform int uRenderBackground;

varying vec2 vTexCoord;
varying vec4 vColor;

float unpackSamples(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

void main()
{
	vec4 samplesExp = texture2D(uSamplesExp, vTexCoord);
	vec4 samplesDec = texture2D(uSamplesDec, vTexCoord);
	
	vec4 result = vec4(0.0, 0.0, 0.0, 1.0);
	
	result.r = (unpackSamples(samplesExp.r, samplesDec.r) * uSamplesStrength) / (255.0 * 255.0);
	result.g = (unpackSamples(samplesExp.g, samplesDec.g) * uSamplesStrength) / (255.0 * 255.0);
	result.b = (unpackSamples(samplesExp.b, samplesDec.b) * uSamplesStrength) / (255.0 * 255.0);
	
	if (uRenderBackground < 1)
	{
		vec4 sampleAlpha = texture2D(uSamplesAlpha, vTexCoord);
		result.a = (unpackSamples(sampleAlpha.r, sampleAlpha.g) * uSamplesStrength) / (255.0 * 255.0);
	}
	
	gl_FragColor = result;
}