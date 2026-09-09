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
#pragma shady: inline(common_util.MATH_FUNC_LIB)
#pragma shady: inline(common_constants.MATH)
#pragma shady: inline(common_raytrace.RAYTRACE_LIB)
#pragma shady: inline(common_material.SAMPLE_GGX_LIB)

void main()
{
	float depth = readDepth(vTexCoord);
	
	// Sample receiver material
	vec3 materialData = texture2D(uMaterialBuffer, vTexCoord).rgb;
	
	// XY hit position, Z confidence
	vec3 rayData = vec3(0.0); 
	
	if (!isDepthBackground(depth) && materialData.r < 0.95)
	{
		// Sample buffers
		vec3 normal	= unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		vec4 noise	= texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize));
		
		// Calculate ray direction
		vec3 rayPos	 = posFromBuffer(vTexCoord, depth);
		vec3 reference = (abs(normal.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0));
		mat3 mat = getTBN(normal, cross(reference, normal));
		
		// Sample GGX VNDF
		vec2 Xi = (noise.rg * 255.0 + vec2(0.5)) / 256.0;
		vec3 viewDir = normalize(-rayPos);
		vec3 localView = vec3(dot(viewDir, mat[0]), dot(viewDir, mat[1]), dot(viewDir, mat[2]));
		vec3 H = normalize(mat * sampleGGXVNDF(Xi, localView, materialData.r));
		vec3 rayDir = reflect(-viewDir, H);
		
		// Samples below the surface contribute no reflection
		// Replacing them with the mirror direction creates a sharp reflection bias
		if (dot(normal, rayDir) > 0.0)
		{
			// Drop raytrace precision with roughness
			float roughnessScale = mix(1.0, 0.25, percent(materialData.r, 0.0, 0.95));
			rayTrace(rayData, rayPos, rayDir, normal, noise.b, roughnessScale);
		}
	}
	
	gl_FragColor = vec4(rayData, 1.0);
}
