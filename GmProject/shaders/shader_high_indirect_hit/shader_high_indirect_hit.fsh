varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNoiseBuffer;
uniform sampler2D uMaterialBuffer;

uniform vec2 uScreenSize;
uniform float uNoiseSize;

#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_util.BLUE_NOISE_DIRECTION_LIB)
#pragma shady: inline(common_raytrace.RAYTRACE_LIB)

void main()
{
	float depth = readDepth(vTexCoord);
	
	// XY hit position, Z confidence
	vec3 rayData = vec3(0.0);
	
	if (!isDepthBackground(depth))
	{
		vec3 materialData = texture2D(uMaterialBuffer, vTexCoord).rgb;
		
		// Skip for fully reflective/metallic
		if (((1.0 - materialData.g) * (1.0 - materialData.b)) <= 0.001)
		{
			gl_FragColor = vec4(rayData, 1.0);
			return;
		}
		
		// Sample buffers
		vec3 normal	= unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		vec4 noise	= texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize));
		
		// Calculate ray direction
		vec3 rayPos	 = posFromBuffer(vTexCoord, depth);
		vec3 reference = (abs(normal.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0));
		mat3 mat = getTBN(normal, cross(reference, normal));
		
		vec3 rayDir = normalize(mat * unpackBlueNoiseDirection(noise));
		
		if (dot(normal, rayDir) > 0.0)
		{
			rayTrace(rayData, rayPos, rayDir, normal, noise.b, 0.75); // 75% quality since GI is mostly diffused
			
			if (rayData.z > 0.0)
			{
				vec3 hitNormal = unpackNormal(texture2D(uNormalBuffer, rayData.xy));
				rayData.z *= max(0.0, dot(-hitNormal, rayDir));
			}
		}
	}
	
	gl_FragColor = vec4(rayData, 1.0);
}
