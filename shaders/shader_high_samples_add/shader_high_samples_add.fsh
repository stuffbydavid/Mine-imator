uniform sampler2D uSamplesExp;
uniform sampler2D uSamplesDec;
uniform sampler2D uSamplesAlpha;
uniform sampler2D uSample;

varying vec2 vTexCoord;

vec2 packSample(float f)
{
	return vec2(floor(f / 255.0) / 255.0, fract(f / 255.0));
}

float unpackSample(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

void main()
{
	vec4 sampleExp = texture2D(uSamplesExp, vTexCoord);
	vec4 sampleDec = texture2D(uSamplesDec, vTexCoord);
	vec4 sampleAlpha = texture2D(uSamplesAlpha, vTexCoord);
	
	vec4 sample = texture2D(uSample, vTexCoord);
	vec2 channel = vec2(0.0);
	
	// Red
	channel = packSample(unpackSample(sampleExp.r, sampleDec.r) + sample.r * 255.0);
	
	gl_FragData[0].r = channel.x;
	gl_FragData[1].r = channel.y;
	
	// Green
	channel = packSample(unpackSample(sampleExp.g, sampleDec.g) + sample.g * 255.0);
	
	gl_FragData[0].g = channel.x;
	gl_FragData[1].g = channel.y;
	
	// Blue
	channel = packSample(unpackSample(sampleExp.b, sampleDec.b) + sample.b * 255.0);
	
	gl_FragData[0].b = channel.x;
	gl_FragData[1].b = channel.y;
	
	gl_FragData[0].a = 1.0;
	gl_FragData[1].a = 1.0;
	
	// Alpha
	channel = packSample(unpackSample(sampleAlpha.r, sampleAlpha.g) + sample.a * 255.0);
	gl_FragData[2] = vec4(channel.x, channel.y, 0.0, 1.0);
}