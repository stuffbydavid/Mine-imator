#pragma shady: skip_compilation
void main() {}

#region RAYTRACE_LIB
#pragma shady: macro_begin RAYTRACE_LIB

uniform mat4 uProjMatrix;
uniform float uRayDistance;
uniform float uPrecision;
uniform float uThickness;

#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)

// Largely based on McGuire and Mara's SSRT https://jcgt.org/published/0003/04/04/paper.pdf
// here be dragons!
void rayTrace(out vec3 rayData, vec3 rayStart, vec3 rayDir, vec3 n, float jitter, float stepScale)
{
	vec3 rayEnd			= rayStart.xyz + rayDir * uRayDistance;
	
	// Shallow-angle rays need a thicker target because one depth value can't describe a surface's full shape
	float grazing		= 1.0 - max(0.0, dot(rayDir, n));
	float thicknessMultiplier = max(1.0, pow(grazing, 6.0) * 100.0);
	float rayThickness	= uThickness * thicknessMultiplier;
	float cameraFacing	= 1.0 - smoothstep(-0.2, 0.2, rayDir.z);
	rayThickness		*= mix(1.0, 5.0, cameraFacing);
	
	// Stop the ray at the camera's near clipping plane so it doesn't travel behind the camera
	if (rayEnd.z < uNear)
	{
		float distanceToNear = (uNear - rayStart.z) / min(rayDir.z, -0.000001);
		rayEnd.xyz = rayStart.xyz + rayDir * max(distanceToNear, 0.0);
	}
	
	vec2 rayPxStart, rayPxEnd, rayPxDis, rayUv, rayUvStart;
	vec4 clipStart	= uProjMatrix * vec4(rayStart, 1.0);
	vec4 clipEnd	= uProjMatrix * vec4(rayEnd, 1.0);
	float invWStart	= 1.0 / clipStart.w;
	float invWEnd	= 1.0 / clipEnd.w;
	vec3 qStart		= rayStart * invWStart;
	vec3 qEnd		= rayEnd * invWEnd;
	
	rayPxStart		= clipStart.xy * invWStart * 0.5 + 0.5;
	rayPxEnd		= clipEnd.xy * invWEnd * 0.5 + 0.5;
	rayPxStart.y	= 1.0 - rayPxStart.y;
	rayPxEnd.y		= 1.0 - rayPxEnd.y;
	rayPxStart		*= uScreenSize;
	rayPxEnd		*= uScreenSize;
	
	// Find where the ray leaves the screen before choosing the step size
	// Otherwise, rays moving toward the camera may skip visible objects
	vec2 viewportMin = vec2(0.5);
	vec2 viewportMax = uScreenSize - vec2(0.5);
	float clipAmount = 0.0;
	
	if (rayPxEnd.y < viewportMin.y || rayPxEnd.y > viewportMax.y)
	{
		float edgeY = (rayPxEnd.y > viewportMax.y ? viewportMax.y : viewportMin.y);
		clipAmount = (rayPxEnd.y - edgeY) / (rayPxEnd.y - rayPxStart.y);
	}
	
	if (rayPxEnd.x < viewportMin.x || rayPxEnd.x > viewportMax.x)
	{
		float edgeX = (rayPxEnd.x > viewportMax.x ? viewportMax.x : viewportMin.x);
		clipAmount = max(clipAmount, (rayPxEnd.x - edgeX) / (rayPxEnd.x - rayPxStart.x));
	}
	
	if (clipAmount > 0.0)
	{
		float endWeight = 1.0 - clamp(clipAmount, 0.0, 1.0);
		rayPxEnd = mix(rayPxStart, rayPxEnd, endWeight);
		
		float invWClipped = mix(invWStart, invWEnd, endWeight);
		vec3 qClipped = mix(qStart, qEnd, endWeight);
		rayEnd = qClipped / invWClipped;
	}
	
	rayPxDis	= rayPxEnd - rayPxStart;
	rayUvStart	= rayPxStart / uScreenSize;
	
	float projectedLength = max(abs(rayPxDis.x), abs(rayPxDis.y));
	
	// Short rays aren't reliable, fade them instead of showing a bad hit
	float rayConfidence = smoothstep(1.0, 4.0, projectedLength); 
	
	// Trace axis the ray travels across the most
	bool rayHit			= false;
	bool rayVertical	= (abs(rayPxDis.y) > abs(rayPxDis.x));
	
	if (rayVertical)
	{
		rayPxStart	= rayPxStart.yx;
		rayPxDis	= rayPxDis.yx;
	}
	
	// A ray shorter than one screen pixel can't be traced reliably
	if (projectedLength < 1.0)
	{
		rayData = vec3(0.0);
		return;
	}
	
	vec2 stepPx = rayPxDis / max(abs(rayPxDis.x), 0.001);
	
	// Put the axes back in screen order before creating the texture-coordinate step
	vec2 uvStep = ((rayVertical ? stepPx.yx : stepPx.xy) / uScreenSize);
	
	float sampleDepth = 1.0;
	
	/*
		- 16 steps min (lowest surface quality)
		- 128 steps max (full precision, full/mirror-like quality)
	*/
	float steps = max(16.0, (32.0 + 96.0 * uPrecision) * stepScale);
	
	float i = 0.0;
	float rayPixelLength = abs(rayPxDis.x);
	float invRayPixelLength = 1.0 / rayPixelLength;
	float rayDepthProduct = rayStart.z * rayEnd.z;
	float nearStepCount = min(8.0, steps);
	float farStride = max(1.0, (rayPixelLength - nearStepCount) / max(steps - nearStepCount, 1.0));
	float progressEnd = 0.0;
	float previousRayDepth = rayStart.z;
	bool previousRayDepthValid = true;
	
	for (; i < steps; i += 1.0)
	{
		// Take small steps near the start so the ray doesn't skip close objects
		// Take larger steps farther away to stay within the step limit
		float stride = (i < nearStepCount ? 1.0 : farStride);
		float progressStart = progressEnd;
		progressEnd = min(progressStart + stride, rayPixelLength);
		
		// Randomize coarse samples so large strides don't form coherent depth bands
		float stepOffset = (i < nearStepCount ? 0.5 : mix(0.2, 0.8, jitter));
		float progress = mix(progressStart, progressEnd, stepOffset);
		rayUv = rayUvStart + (uvStep * progress);
		
		if (rayUv.x < 0.0 || rayUv.y < 0.0 || rayUv.x > 1.0 || rayUv.y > 1.0)
			break;
		
		sampleDepth = readDepth(rayUv);
		
		if (isDepthBackground(sampleDepth))
		{
			previousRayDepthValid = false;
			
			if (progressEnd >= rayPixelLength)
				break;
			
			continue;
		}
		
		// Check whether the ray crossed a surface during this step
		// Allow some thickness because the depth buffer only stores the surface itself
		float progressMinPx = progressStart * invRayPixelLength;
		float progressMaxPx = progressEnd * invRayPixelLength;
		float rayDepthA = (previousRayDepthValid ? previousRayDepth : rayDepthProduct / mix(rayEnd.z, rayStart.z, progressMinPx));
		float rayDepthB = rayDepthProduct / mix(rayEnd.z, rayStart.z, progressMaxPx);
		float rayDepthMin = min(rayDepthA, rayDepthB);
		float rayDepthMax = max(rayDepthA, rayDepthB);
		previousRayDepth = rayDepthB;
		previousRayDepthValid = true;
		float sceneDepthMin = sampleDepth * (uFar - uNear) + uNear;
		float sceneDepthMax = sceneDepthMin + rayThickness;
		
		rayHit = rayDepthMax >= sceneDepthMin && rayDepthMin <= sceneDepthMax;
		
		if (rayHit)
		{
			// Backface check
			vec3 hitNormal = unpackNormal(texture2D(uNormalBuffer, rayUv));
			rayHit = dot(hitNormal, rayDir) < 0.0;
		}
		
		if (rayHit || progressEnd >= rayPixelLength)
			break;
	}
	
	// Depth check
	if (!rayHit || isDepthBackground(sampleDepth))
	{
		rayData = vec3(0.0);
		return;
	}
	
	rayData = vec3(rayUv, rayConfidence);
}

#pragma shady: macro_end
#endregion
