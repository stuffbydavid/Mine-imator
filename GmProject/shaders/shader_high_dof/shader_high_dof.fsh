uniform sampler2D uBlurBuffer;
uniform vec2 uScreenSize;
uniform float uBlurSize;

uniform float uBias;
uniform float uThreshold;
uniform float uGain;

uniform int uFringe;
uniform vec3 uFringeAngle;
uniform vec3 uFringeStrength;

uniform int uSampleAmount;
uniform vec2 uSamples[128];
uniform float uWeightSamples[128];

varying vec2 vTexCoord;

float getBlur(vec2 coord)
{
	vec2 blur = texture2D(uBlurBuffer, coord).xy;
	return clamp(blur.x + blur.y, 0.0, 1.0);
}

vec4 getFringe(vec2 coord, float blur, vec4 color)
{
	float screenSampleSize = uScreenSize.y * uBlurSize;
	vec2 texelSize = 1.0 / uScreenSize;
	vec4 baseColor = color;
	
	if (uFringe < 1)
		return baseColor;
	
	float fringeSize = texelSize.x * blur * screenSampleSize;
	
	vec2 redOffset = vec2(cos(uFringeAngle.x), sin(uFringeAngle.x)) * (uFringeStrength.x * fringeSize);
	float redBlur = getBlur(coord + redOffset);
	baseColor.r = texture2D(gm_BaseTexture, coord + redOffset * redBlur).r;
	
	vec2 greenOffset = vec2(cos(uFringeAngle.y), sin(uFringeAngle.y)) * (uFringeStrength.y * fringeSize);
	float greenBlur = getBlur(coord + greenOffset);
	baseColor.g = texture2D(gm_BaseTexture, coord + greenOffset * greenBlur).g;
	
	vec2 blueOffset = vec2(cos(uFringeAngle.z), sin(uFringeAngle.z)) * (uFringeStrength.z * fringeSize);
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
	vec2 blurTex = texture2D(uBlurBuffer, vTexCoord).xy;
	float myBlur = clamp(blurTex.r + blurTex.g, 0.0, 1.0);
	
	float blur = 0.0;
	float colorDiv = 0.0;
	vec4 colorAdd = vec4(0.0);
	float weightStrength = 0.0;
	float blurAmount = myBlur * screenSampleSize;
	gl_FragColor = vec4(0.0);
	
	// Don't go through samples if there's no blur needed
	if (blurAmount > 0.0)
	{	
		// Sample positions
		for (int i = 0; i < 128; i++)
		{
			if (i >= uSampleAmount)
				break;
			
			if (uWeightSamples[i] < 0.05)
				continue;
			
			vec2 offset = uSamples[i].xy * blurAmount;
			vec2 tex = vTexCoord + texelSize * offset;
			
			float sampleBlur = getBlur(tex);
			float bias = mix(1.0, smoothstep(0.0, 1.0, uWeightSamples[i]), uBias);
			
			float mul = (1.0 - (1.0 - sampleBlur) * myBlur) * bias;	
			
			blur += sampleBlur;
			if (mul > 0.0)
			{
				colorAdd += getColor(tex, sampleBlur) * mul;
				colorDiv += mul;
			}
			
			weightStrength += bias;
		}
		
		blur /= weightStrength;
		blur += myBlur;
		
		colorAdd *= blur;
		colorDiv *= blur;
		
		gl_FragColor += colorAdd;
		gl_FragColor /= colorDiv;
	}
	else
		gl_FragColor = texture2D(gm_BaseTexture, vTexCoord);
}
