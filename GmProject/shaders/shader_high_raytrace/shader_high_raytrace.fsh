#define up vec3(0.0, 0.0, 1.0)
#define RAY_SPECULAR 0
#define RAY_DIFFUSE 1

varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNoiseBuffer;

// Material for reflections, emissive for indirect
uniform sampler2D uMaterialBuffer;

// Specular tint for reflections, diffuse for indirect
uniform sampler2D uDiffuseBuffer;

// Scene color for reflections, shadows for indirect
uniform sampler2D uDataBuffer;

// Scene data
uniform vec4 uSkyColor;

// Camera data
uniform mat4 uProjMatrix;
uniform vec2 uScreenSize;

uniform float uPrecision;
uniform float uThickness;
uniform float uNoiseSize;

uniform int uRayType;
uniform float uRayDistance;

// Reflections
uniform float uFadeAmount;
uniform float uGamma;

// Indirect
uniform float uIndirectStength;

uniform float uSampleIndex;

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.BLUE_NOISE_DIRECTION_LIB)
#pragma shady: inline(common_util.SAMPLING_LIB)
#pragma shady: inline(common_constants.MATH)
#pragma shady: inline(common_material.SAMPLE_GGX_LIB)

vec2 viewPosToPixel(vec3 viewPos)
{
	vec4 coord	= (uProjMatrix * vec4(viewPos, 1.0));
	coord.xy	= (coord.xy / coord.w) * 0.5 + 0.5;
	coord.y		= 1.0 - coord.y;
	coord.xy	*= uScreenSize;
	
	return floor(coord.xy);
}

float percent(float xx, float start, float end)
{
	return clamp((xx - start) / (end - start), 0.0, 1.0);
}

vec3 rayTrace(vec3 rayStart, vec3 rayDir, float rayThickness, vec3 noise)
{
	// Ray data
	vec3 rayEnd			= rayStart.xyz + rayDir * uRayDistance;
	
	// Clip to near camera plane
	if (rayEnd.z < uNear)
		rayEnd.xyz	= rayStart.xyz + (rayDir * (rayStart.z - uNear));
	
	vec2 rayPx, rayPxStart, rayPxEnd, rayPxDis, rayUv, rayUvStart;
	rayPxStart	= viewPosToPixel(rayStart);
	rayPxEnd	= viewPosToPixel(rayEnd);
	rayPxDis	= rayPxEnd - rayPxStart;
	rayUvStart	= rayPxStart / uScreenSize;
	float thickness = rayThickness;
	
	// Get pixel data for line tracing, swizzel to keep longest axis in X
	bool rayHit	= false;
	bool rayVertical	= (abs(rayPxDis.y) > abs(rayPxDis.x));
	
	if (rayVertical)
	{
		rayPxStart	= rayPxStart.yx;
		rayPxDis	= rayPxDis.yx;
	}
	
	vec2 stepPx = rayPxDis / max(abs(rayPxDis.x), 0.001);
	
	// Correct swizzel, UV coords needs to be correct
	vec2 uvStep = ((rayVertical ? stepPx.yx : stepPx.xy) / uScreenSize);
	
	float progress, progressPrev, p;
	float rayZ, sampleZ, delta, deltaPrev;
	float sampleDepth;
	progress = 1.001;
	p = progress;
	
	float i = 0.0;
	float steps = 256.0 * (1.0 + uPrecision); // Gradually increase max steps
	float stepscount = 0.0;
	float precisionJitter = (uRayType == RAY_SPECULAR ? 1.0 : noise.g);
	for (; i < steps; i += 1.0)
	{
		// Get previous progress for refining later
		progressPrev	= progress;
		deltaPrev		= delta;
		
		float stride	= 1.0 + ((i * (1.0 - uPrecision)) * precisionJitter);
		progress		= p + (stride * noise.r);
		p				+= stride;
		
		// Move forward
		rayUv	= rayUvStart + (uvStep * progress);
		
		if (rayUv.x < 0.0 || rayUv.y < 0.0 || rayUv.x > 1.0 || rayUv.y > 1.0)
			break;
		
		sampleDepth = readDepth(rayUv);
		
		if (isDepthBackground(sampleDepth))
			continue;
		
		// Get ray/scene depth
		float progressPx = (stepPx.x * progress) / rayPxDis.x;
		
		// Past end point
		if (progressPx > 1.0)
			break;
		
		rayZ		= (rayStart.z * rayEnd.z) / mix(rayEnd.z, rayStart.z, progressPx);
		sampleZ		= posFromBuffer(rayUv, sampleDepth).z;
		thickness	= rayThickness * max(1.0, pow(sampleDepth, 5.0) * 1500.0);
		
		// Distance between ray Z and object Z
		delta	= sampleZ - rayZ;
		
		// Negative depth, check for collision
		rayHit	= (delta < 0.0);
		rayHit	= rayHit && ((delta > -thickness) || abs(delta) < abs(rayDir.z * stride * 2.0));
		
		if (rayHit || (rayZ - rayStart.z > uRayDistance))
			break;
		
		stepscount++;
	}
	
	// Prevent backface hit
	rayHit = rayHit && (deltaPrev > 0.0);
	
	// Depth check
	if (!rayHit || isDepthBackground(sampleDepth))
		return vec3(-1.0, -1.0, stepscount);
	
	// Refine
	progress = mix(progressPrev, progress, clamp(deltaPrev / (deltaPrev - delta), 0.0, 1.0));
	rayUv = rayUvStart + (uvStep * progress);
	
	return vec3(rayUv, stepscount);
}

void main()
{
	// Depth quick exit
	float depth = readDepth(vTexCoord);
	
	// Sample material (Specular only)
	vec3 materialData = vec3(0.0);
	if (uRayType == RAY_SPECULAR)
		materialData = texture2D(uMaterialBuffer, vTexCoord).rgb;
	
	vec3 normal = vec3(0.0);
	vec3 rayDir = vec3(0.0);
	
	vec3 rayCoord = vec3(-1.0);
	
	float pixel = (floor(vTexCoord.x * uScreenSize.x) + floor(vTexCoord.y * uScreenSize.y)) + uSampleIndex;
	bool halfResCast = (mod(pixel, 2.0) == 0.0);
	
	// Don't calculate ray if depth isn't valid
	if (!(isDepthBackground(depth) || materialData.r > 0.95 || !halfResCast))
	{
		// Sample buffers
		normal	= unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		vec4 noise	= texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize));
	
		// Calculate ray direction
		vec3 rayPos	 = posFromBuffer(vTexCoord, depth);
		vec3 tangent = normalize(up - normal * dot(up, normal));
		mat3 mat	 = mat3(tangent, cross(normal, tangent), normal);
		
		// Specular (GGX)
		if (uRayType == RAY_SPECULAR)
		{
			for (int i = 0; i < 3; i++)
			{
				vec2 Xi = hammersley(int(256.0 + ((noise.r - .5) * 256.0)), 512);
				vec3 H  = normalize(mat * sampleGGX(Xi, materialData.r));
				rayDir = reflect(normalize(rayPos), H);
			
				if (dot(normal, rayDir) > 0.0)
					break;
			}
		}
		else // Diffuse
			rayDir = normalize(mat * unpackBlueNoiseDirection(noise));
	
		// Ray thickness (Increase based on steepness of ray)
		float rayThickness = uThickness * max(1.0, pow(1.0 - abs(max(0.0, dot(rayDir, normal))), 6.0) * 100.0);
		
		if (rayDir.z < 0.2)
			rayThickness *= 5.0;
		
		// Ray trace
		rayCoord = rayTrace(rayPos, rayDir, rayThickness, noise.rgb);
	}
	
	vec3 rayColor = uSkyColor.rgb;
	vec3 hitNormal = vec3(0.0);
	
	if (rayCoord.x > 0.0)
	{
		hitNormal = unpackNormal(texture2D(uNormalBuffer, rayCoord.xy));
		
		if (dot(hitNormal, normal) > 0.5)
			rayCoord.x = -1.0;
	}
	
	// Specular
	if (uRayType == RAY_SPECULAR)
	{
		// Fade by edge
		float vis = (rayCoord.x > 0.0 ? 1.0 : 0.0);
		
		if (rayCoord.x > 0.0)
		{
			vec2 fadeUV = smoothstep(0.2, 0.6, abs(vec2(0.5, 0.5) - rayCoord.xy)) * uFadeAmount;
			vis *= clamp(1.0 - (fadeUV.x + fadeUV.y), 0.0, 1.0);
			
			// Fade if roughness is too high
			vis *= 1.0 - percent(materialData.r, .85, .95);
			vis = clamp(vis, 0.0, 1.0);
			
			rayColor = texture2D(uDataBuffer, rayCoord.xy).rgb;
		}
		
		// Get color
		rayColor = mix(pow(uSkyColor.rgb, vec3(uGamma)), rayColor, vis);
		
		// Specular tint from metallic
		if (materialData.g > 0.0)
			rayColor *= mix(vec3(1.0), pow(texture2D(uDiffuseBuffer, vTexCoord).rgb, vec3(uGamma)), materialData.g);
		
		// Multiply by fresnel
		rayColor *= materialData.b;
		
		gl_FragColor = vec4(rayColor, 1.0);
	}
	else // Diffuse
	{
		vec3 light = vec3(0.0);		
		
		if (rayCoord.x > 0.0)
		{
			// Get direct light and emissive
			light = (texture2D(uDataBuffer, rayCoord.xy).rgb + texture2D(uNormalBuffer, rayCoord.xy).a) * uIndirectStength;
			
			// Diffuse tint
			light *= pow(texture2D(uDiffuseBuffer, rayCoord.xy).rgb, vec3(uGamma));
			
			// Multiply by diffuse & strength
			light *= max(0.0, dot(-hitNormal, rayDir));
		}
		
		gl_FragColor = vec4(light, 1.0);
	}
	
	// Debug XY hit coords(RG) and steps(B)
	//if (vTexCoord.x < 0.0)
	//	gl_FragColor = vec4(rayCoord.xy, rayCoord.z/256.0, 1.0);
}
