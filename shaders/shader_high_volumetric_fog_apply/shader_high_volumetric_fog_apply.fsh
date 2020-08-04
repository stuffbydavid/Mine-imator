uniform sampler2D uSamplesExp;
uniform sampler2D uSamplesDec;

uniform float uSamplesStrength;
uniform vec4 uColor;
uniform vec4 uSunColor;
uniform vec4 uAmbientColor;
uniform float uFogBrightness;

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
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	float opacity = (unpackSamples(samplesExp.r, samplesDec.r) * uSamplesStrength) / (255.0 * 255.0);
	float color = (unpackSamples(samplesExp.g, samplesDec.g) * uSamplesStrength) / (255.0 * 255.0);
	color *= 4.0;
	
	vec3 fogLight = (uAmbientColor.rgb + (uSunColor.rgb * color));
	vec3 fogColor = uColor.rgb * mix(fogLight, vec3(1.0), uFogBrightness);
	baseColor.rgb = mix(baseColor.rgb, fogColor, opacity);
	
	gl_FragColor = baseColor;
}