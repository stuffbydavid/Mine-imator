#define DEPTH_SENSITIVITY 20.0
#define SAMPLES 4

varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform vec2 uScreenSize;
uniform vec2 uPixelCheck;

// Get Depth Value
float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

// Get Normal Value
vec3 unpackNormal(vec4 c)
{
	return c.rgb * 2.0 - 1.0;
}

void main()
{
	float centerDepth = unpackDepth(texture2D(uDepthBuffer, vTexCoord));
	vec3 centerNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
	
	// Turn the pixel into a texel. As depth increases, the radius decreases.
	vec2 texelCheck = (uPixelCheck / uScreenSize) * (1.0 - centerDepth);
	
	// Setup blur weights
	float weights[SAMPLES + 1];
	weights[0] = 70.0;
	weights[1] = 56.0;
	weights[2] = 28.0;
	weights[3] = 8.0;
	weights[4] = 1.0;
	
	vec4 ssao = texture2D(gm_BaseTexture, vTexCoord) * weights[0];
	float totalWeight = weights[0];
	
	// Sample dis crap
	for (int i = 0; i < SAMPLES; i += 1)
	{
		// Get the sample uv coordinates
		vec2 sampleOffset = float(i + 1) * texelCheck;
		
		// Positive direction
		vec2 sampleCoords = vTexCoord + sampleOffset;
		float sampleDepth  = unpackDepth(texture2D(uDepthBuffer, sampleCoords));
		vec3 sampleNormal = unpackNormal(texture2D(uNormalBuffer, sampleCoords)); 
		float weight = max(0.0, dot(centerNormal, sampleNormal) - abs(sampleDepth - centerDepth) * DEPTH_SENSITIVITY) * weights[i + 1];
		ssao += texture2D(gm_BaseTexture, sampleCoords) * weight;
		totalWeight += weight;
		
		// Negative direction
		sampleCoords = vTexCoord - sampleOffset;
		sampleDepth  = unpackDepth(texture2D(uDepthBuffer, sampleCoords ));
		sampleNormal = unpackNormal(texture2D(uNormalBuffer, sampleCoords));
		weight = max(0.0, max(0.0, dot(centerNormal, sampleNormal) * 0.8 + 0.2) - abs(sampleDepth - centerDepth) * DEPTH_SENSITIVITY) * weights[i + 1];
		ssao += texture2D(gm_BaseTexture, sampleCoords) * weight;
		totalWeight += weight;
	}

	gl_FragColor = ssao / totalWeight;
}

