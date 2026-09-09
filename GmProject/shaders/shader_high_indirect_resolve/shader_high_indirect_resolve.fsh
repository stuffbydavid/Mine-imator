varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uSourceBuffer;

uniform vec2 uRayDataSize;
uniform float uStrength;

uniform int uSampleAmount;
uniform vec2 uSamples[25];

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.NEIGHBOR_FILTER_LIB)
#pragma shady: inline(common_color.RADIANCE_LIB)

vec4 sampleNeighbor(vec2 sampleCoord, vec3 originPos, vec3 originNormal, vec3 originMat)
{
	// Filter by neighbor similarity to prevent leaking
	float surfaceWeight = getNeighborSurfaceWeight(sampleCoord, originPos, originNormal);
	if (surfaceWeight < 0.001)
		return vec4(0.0);
	
	vec3 sampleMat = texture2D(uMaterialBuffer, sampleCoord).rgb;
	float materialWeight = 1.0 - smoothstep(0.05, 0.25, abs(sampleMat.g - originMat.g));
	surfaceWeight *= materialWeight;
	
	if (surfaceWeight < 0.001)
		return vec4(0.0);
	
	vec3 light = vec3(0.0);
	vec4 rayData = texture2D(gm_BaseTexture, sampleCoord);
	
	if (rayData.z > 0.0)
	{
		vec2 hitUv = rayData.xy;
		float hitDepth = readDepth(hitUv);
		
		if (!isDepthBackground(hitDepth))
			light = texture2D(uSourceBuffer, hitUv).rgb * rayData.z;
	}
	
	// Compress light to prevent fireflies (later expanded after accumulation)
	return vec4(compressRadiance(light) * surfaceWeight, surfaceWeight);
}

void main()
{
	float depth = readDepth(vTexCoord);
	vec3 light = vec3(0.0);
	
	if (!isDepthBackground(depth))
	{
		vec3 originNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		vec3 originMat = texture2D(uMaterialBuffer, vTexCoord).rgb;
		vec3 originPos = posFromBuffer(vTexCoord, depth);
		vec2 texelSize = 1.0 / uRayDataSize;
		vec2 rayPixelCenter = (floor(vTexCoord * uRayDataSize) + vec2(0.5)) * texelSize;
		vec4 samples = vec4(0.0);
		
		for (int i = 0; i < 25; i++)
		{
			if (i >= uSampleAmount)
				break;
			
			vec2 samplePos = rayPixelCenter + texelSize * uSamples[i];
			samples += sampleNeighbor(samplePos, originPos, originNormal, originMat);
		}

		if (samples.a > 0.001)
		{
			light = expandRadiance(samples.rgb / samples.a);
			
			// The final scene pass applies this surface's color, so only its diffuse response belongs here
			float diffuseResponse = (1.0 - originMat.g) * (1.0 - originMat.b);
			light *= diffuseResponse * uStrength;
		}
	}
	
	gl_FragColor = vec4(light, 1.0);
}
