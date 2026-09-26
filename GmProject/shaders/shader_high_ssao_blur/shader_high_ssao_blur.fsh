#define SAMPLES 4

varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform vec2 uScreenSize;
uniform vec2 uPixelCheck;

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.NEIGHBOR_FILTER_LIB)

void main()
{
	float centerDepth = readDepth(vTexCoord);
	if (isDepthBackground(centerDepth))
		discard;
	
	vec3 centerNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
	vec3 centerPos = posFromBuffer(vTexCoord, centerDepth);
	
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
	
	for (int i = 0; i < SAMPLES; i++)
	{
		vec2 sampleOffset = float(i + 1) * texelCheck;
		
		// Positive direction
		vec2 sampleCoords = vTexCoord + sampleOffset;
		float weight = getNeighborSurfaceWeight(sampleCoords, centerPos, centerNormal) * weights[i + 1];
		ssao += texture2D(gm_BaseTexture, sampleCoords) * weight;
		totalWeight += weight;
		
		// Negative direction
		sampleCoords = vTexCoord - sampleOffset;
		weight = getNeighborSurfaceWeight(sampleCoords, centerPos, centerNormal) * weights[i + 1];
		ssao += texture2D(gm_BaseTexture, sampleCoords) * weight;
		totalWeight += weight;
	}

	gl_FragColor = ssao / totalWeight;
}
