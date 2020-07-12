uniform sampler2D uSamplesExp;
uniform sampler2D uSamplesDec;

uniform float uSamplesStrength;

varying vec2 vTexCoord;
varying vec4 vColor;

float unpackSamples(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

void main()
{
	vec3 samplesExp = texture2D(uSamplesExp, vTexCoord).rgb;
	vec3 samplesDec = texture2D(uSamplesDec, vTexCoord).rgb;
	
	vec3 light = vec3(0.0);
	
	light.r = (unpackSamples(samplesExp.r, samplesDec.r) * uSamplesStrength) / (255.0 * 255.0);
	light.g = (unpackSamples(samplesExp.g, samplesDec.g) * uSamplesStrength) / (255.0 * 255.0);
	light.b = (unpackSamples(samplesExp.b, samplesDec.b) * uSamplesStrength) / (255.0 * 255.0);
	
	gl_FragColor = vec4(light, 1.0);
}