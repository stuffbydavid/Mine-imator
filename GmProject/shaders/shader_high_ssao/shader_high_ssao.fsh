#define SAMPLES 12

varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uEmissiveBuffer;
uniform sampler2D uNoiseBuffer;
uniform sampler2D uMaskBuffer;

uniform mat4 uProjMatrix;

uniform vec2 uScreenSize;
uniform float uNoiseSize;

uniform vec3 uKernel[SAMPLES];
uniform float uRadius;
uniform float uPower;
uniform vec4 uColor;

#pragma shady: inline(common_util.UNPACK_VALUE_LIB)
#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.BLUE_NOISE_KERNEL_SEED_LIB)

float getSSAOstrength(vec2 uv)
{
	float emissive = unpackValue(texture2D(uEmissiveBuffer, uv)) * 255.0;
	float mask = texture2D(uMaskBuffer, uv).r;
	return (1.0 - clamp(emissive, 0.0, 1.0)) * mask;
}

void main()
{
	// Perform alpha test to ignore background
	float originDepth = readDepth(vTexCoord);
	if (isDepthBackground(originDepth))
		discard;
	
	// Get view space origin
	vec3 origin = posFromBuffer(vTexCoord, originDepth);
	
	// Get scaled radius
	float sampleRadius = uRadius * (1.0 - originDepth);
	
	// Get normal
	vec3 normal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
	
	// Random vector from noise
	vec2 noiseScale = uScreenSize / uNoiseSize;
	vec3 randVec	= unpackBlueNoiseKernelSeed(texture2D(uNoiseBuffer, vTexCoord * noiseScale));

	// Construct kernel basis matrix
	vec3 tangent = normalize(randVec - normal * dot(randVec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 kernelBasis = mat3(tangent, bitangent, normal);
	
	// Calculate occlusion factor
	float occlusion = 0.0;
	for (int i = 0; i < SAMPLES; i++)
	{
		// Get sample position
		vec3 samplePos = origin + (kernelBasis * uKernel[i]) * sampleRadius;
		
		// Project sample position
		vec4 sampleScreen = uProjMatrix * vec4(samplePos, 1.0);
		vec2 sampleCoord = (sampleScreen.xy / sampleScreen.w) * 0.5 + 0.5;
		sampleCoord.y = 1.0 - sampleCoord.y;
		
		// Get sample depth
		float sampleDepth = posFromBuffer(sampleCoord, readDepth(sampleCoord)).z;
		
		// Get sample strength
		float sampleStrength = getSSAOstrength(sampleCoord);
		
		// Sample normal
		vec3 sampleNormal = unpackNormal(texture2D(uNormalBuffer, sampleCoord));
		
		// Add occlusion if checks succeed
		float bias = originDepth * 50.0;
		float depthCheck = (sampleDepth <= (samplePos.z - bias)) ? 1.0 : 0.0;
		float rangeCheck = smoothstep(0.0, 1.0, sampleRadius / abs(origin.z - sampleDepth));
		float angleCheck = clamp((1.0 - dot(sampleNormal, normal)) * 2.0, 0.0, 1.0);
		occlusion += depthCheck * rangeCheck * sampleStrength * angleCheck;
	}
	
	// Raise to power
	occlusion = clamp(1.0 - pow(max(0.0, 1.0 - occlusion / float(SAMPLES)), uPower), 0.0, 1.0);
	
	// Apply strength
	occlusion *= getSSAOstrength(vTexCoord);
	occlusion = clamp(occlusion, 0.0, 1.0);
	
	// Mix
	gl_FragColor = mix(vec4(1.0), uColor, occlusion);
}
