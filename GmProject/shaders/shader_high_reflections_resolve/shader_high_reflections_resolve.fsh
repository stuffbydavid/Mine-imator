varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNoiseBuffer;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uSceneBuffer;
uniform sampler2D uMetallicBuffer;

uniform vec4 uSkyColor;
uniform vec2 uScreenSize;
uniform vec2 uRayDataSize;
uniform float uNoiseSize;
uniform float uFadeAmount;
uniform float uGamma;

uniform int uSampleAmount;
uniform vec2 uSamples[25]; // Either 3x3 (9) or 5x5 (25) neighbor kernel

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.NEIGHBOR_FILTER_LIB)
#pragma shady: inline(common_util.MATH_FUNC_LIB)
#pragma shady: inline(common_color.RADIANCE_LIB)

vec4 sampleNeighbor(vec2 sampleCoord, vec3 originPos, vec3 originNormal, vec3 originMat)
{
	// Filter by neighbor similarity to prevent leaking
	float surfaceWeight = getNeighborSurfaceWeight(sampleCoord, originPos, originNormal);
	if (surfaceWeight < 0.001)
		return vec4(0.0);
	
	vec3 sampleMat = texture2D(uMaterialBuffer, sampleCoord).rgb;
	float roughnessWeight = 1.0 - smoothstep(0.05, 0.25, abs(sampleMat.r - originMat.r));
	surfaceWeight *= roughnessWeight;
	
	if (surfaceWeight < 0.001)
		return vec4(0.0);
	
	vec3 sky = pow(uSkyColor.rgb, vec3(uGamma));
	vec3 col = sky;
	vec4 rayData = texture2D(gm_BaseTexture, sampleCoord);
	
	if (rayData.z > 0.0)
	{
		vec2 hitUv = rayData.xy;
		float hitDepth = readDepth(hitUv);
		
		if (!isDepthBackground(hitDepth))
		{
			// Screen fade
			vec2 fadeUv = smoothstep(0.2, 0.6, abs(vec2(0.5) - hitUv)) * uFadeAmount;
			float hitVis = clamp(1.0 - fadeUv.x - fadeUv.y, 0.0, 1.0) * rayData.z;
			col = mix(sky, texture2D(uSceneBuffer, hitUv).rgb, hitVis);
		}
	}
	
	// Compress col to prevent fireflies (later expanded after accumulation)
	return vec4(compressRadiance(col) * surfaceWeight, surfaceWeight);
}

void main()
{
	vec2 texelSize = 1.0 / uRayDataSize;
	vec2 rayPixelCenter = (floor(vTexCoord * uRayDataSize) + vec2(0.5)) * texelSize;
	vec4 col = vec4(0.0);
	float depth = readDepth(vTexCoord);
	vec3 sky = pow(uSkyColor.rgb, vec3(uGamma));
	
	if (!isDepthBackground(depth))
	{
		vec3 originMatData = texture2D(uMaterialBuffer, vTexCoord).rgb;
		vec3 originNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		vec3 originPos = posFromBuffer(vTexCoord, depth);
		
		vec2 samplePos;
		for (int i = 0; i < 25; i++)
		{
			if (i >= uSampleAmount)
				break;
			
			samplePos = rayPixelCenter + texelSize * uSamples[i].xy;
			col += sampleNeighbor(samplePos, originPos, originNormal, originMatData);
		}
		
		if (col.a > 0.001)
		{
			col.rgb /= col.a;
			col.rgb = expandRadiance(col.rgb);
		}
		else
			col.rgb = sky;
		
		// Rough surfaces eventually use the sky because their reflections aren't reliable in screen space
		float roughnessVis = 1.0 - percent(originMatData.r, .85, .95);
		col.rgb = mix(sky, col.rgb, clamp(roughnessVis, 0.0, 1.0));
		
		// Metallic tint
		if (originMatData.g > 0.0)
			col.rgb *= mix(vec3(1.0), pow(texture2D(uMetallicBuffer, vTexCoord).rgb, vec3(uGamma)), originMatData.g);
		
		// Fresnel
		col.rgb *= originMatData.b;
	}
	
	gl_FragColor = vec4(col.rgb, 1.0);
}
