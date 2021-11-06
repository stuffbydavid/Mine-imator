varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uNoiseBuffer;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform mat4 uViewMatrix;
uniform mat4 uViewMatrixInv;
uniform float uNear;
uniform float uFar;
uniform vec2 uScreenSize;

uniform float uPrecision;
uniform float uThickness;
uniform vec3 uKernel[16];
uniform float uOffset[16];
uniform vec4 uFallbackColor;
uniform float uFadeAmount;
uniform float uNoiseSize;

// Get normal Value
vec3 unpackNormal(vec4 c)
{
	return c.rgb * 2.0 - 1.0;
}

// Unpacks depth value from packed color
float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

// Returns depth value from packed depth buffer
float getDepth(vec2 coords)
{
	return unpackDepth(texture2D(uDepthBuffer, coords));
}

// Transforms Z depth with camera data
float transformDepth(float depth)
{
	return (uFar - (uNear * uFar) / (depth * (uFar - uNear) + uNear)) / (uFar - uNear);
}

// Reconstruct a position from a screen space coordinate and (linear) depth
vec4 posFromBuffer(vec2 coord, float depth)
{
	vec4 pos = uProjMatrixInv * vec4(coord.x * 2.0 - 1.0, 1.0 - coord.y * 2.0, transformDepth(depth), 1.0);
	return vec4(pos.xyz / pos.w, pos.w);
}

float unpackFloat2(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

// Get normal Value
vec3 getNormal(vec2 coords)
{
	vec3 nDec = texture2D(uNormalBuffer, coords).rgb;
	vec3 nExp = texture2D(uNormalBufferExp, coords).rgb;
	
	return (vec3(unpackFloat2(nExp.r, nDec.r), unpackFloat2(nExp.g, nDec.g), unpackFloat2(nExp.b, nDec.b)) / (255.0 * 255.0)) * 2.0 - 1.0;
}

vec2 viewPosToPixel(vec4 viewPos)
{
	viewPos     *= uProjMatrix;
	viewPos.xyz /= viewPos.w;
	viewPos.xy   = viewPos.xy * 0.5 + 0.5;
	viewPos.xy  *= uScreenSize;
	
	return viewPos.xy;
}

// Ray tracer, returns color
vec3 rayTrace(vec2 originUV)
{
	vec3 traceCol = vec3(0.0);
	
	// Material from UV
	vec3 mat = texture2D(uMaterialBuffer, originUV).rgb;
	
	// Sample buffers
	float originDepth = getDepth(originUV);
	vec4 viewPos = posFromBuffer(originUV, originDepth);
	vec3 worldPos = vec3(vec4(viewPos.xyz, 1.0) * uViewMatrixInv);
	vec3 normal = getNormal(originUV);
	
	vec3 jitt = vec3(0.0);
	
	// Not physically accurate, but looks nice.
	float roughness = mix(0.0, 1.0, pow(mat.g, 2.5));
	vec3 randVec = unpackNormal(texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)));
	vec3 tangent = normalize(randVec - normal * dot(randVec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 kernelBasis = mat3(tangent, bitangent, normal);
	
	vec3 reflectVector = normalize(reflect(normalize(viewPos.xyz), normalize(normal)));
	vec3 rayVector = normalize(reflect(normalize(viewPos.xyz), normalize(normal + (kernelBasis * uKernel[0] * roughness))));
	float rayVis = 1.0;
	
	if (dot(rayVector, normal) <= 0.01)
		rayVis = 0.0;
	
	// Pixel coord on texture
	vec2 pixelCoord = uScreenSize / originUV;
	
	// Ray data
	float raySize       = 5000.0;
	vec3 rayStartPos    = viewPos.xyz;
	vec3 rayEndPos      = rayStartPos + (rayVector * raySize);
	
	// Clip to near camera plane
	if (rayEndPos.z < uNear)
		rayEndPos       = rayStartPos + (rayVector * (rayStartPos.z - uNear));
	
	vec2 rayStartPixel  = viewPosToPixel(vec4(rayStartPos, 1.0));
	vec2 rayEndPixel    = viewPosToPixel(vec4(rayEndPos, 1.0));
	vec2 rayPixel       = rayStartPixel;
	vec2 rayUV          = rayPixel / uScreenSize;
	
	// Trace data
	vec2 pixelDelta     = rayEndPixel - rayStartPixel;
	bool useDeltaX      = (abs(pixelDelta.x) >= abs(pixelDelta.y));
	float stepDelta     = (useDeltaX ? abs(pixelDelta.x) : abs(pixelDelta.y)) * clamp(uPrecision, 0.0, 1.0);
	vec2 pixelStepDelta = pixelDelta / max(stepDelta, 0.001);
	vec4 samplePos      = viewPos;
	
	int refineSteps = 5;
	float progress = 0.0;
	float progressPrev = 0.0;
	float vis = 0.0;
	
	float viewDist = originDepth;
	float depth    = uThickness;
	float rayThickness = uThickness;
	int traceSteps = int(stepDelta);
	
	int i = 0;
	bool viewClip = false;
	float rayZ = (rayStartPos.z * rayEndPos.z);
	
	for (i = 0; i < traceSteps; i++)
	{
		rayPixel += pixelStepDelta;
		rayUV     = rayPixel / uScreenSize;
		rayUV.x   = 1.0 - rayUV.x;
		
		samplePos = posFromBuffer(rayUV, getDepth(rayUV));
		
		progress  = (useDeltaX ?
					((rayPixel.x - rayStartPixel.x) / pixelDelta.x) :
					((rayPixel.y - rayStartPixel.y) / pixelDelta.y));
		
		progress  = clamp(progress, 0.0, 1.0);
		
		viewDist  = rayZ / mix(rayEndPos.z, rayStartPos.z, progress);
		depth     = samplePos.z - viewDist;
		
		rayThickness = (uThickness * max(1.0, viewDist/25.0));
		
		if (rayUV.x <= 0.0 || rayUV.y <= 0.0 || rayUV.x >= 1.0 || rayUV.y >= 1.0)
		{
			vis = 0.0;
			viewClip = true;
			break;
		}
		
		// Check for collision
		if (depth < 0.0 && depth > -rayThickness)
		{
			vis = 1.0;
			break;
		}
		
		progressPrev = progress;
	}
	
	// Refine ray UV
	if (vis < 1.0)
		refineSteps = 0;
	
	progress = progressPrev + ((progress - progressPrev) * 0.5);
	
	for (int i = 0; i < refineSteps; i++)
	{
		rayPixel  = mix(rayStartPixel, rayEndPixel, progress);
		rayUV     = rayPixel / uScreenSize;
		rayUV.x   = 1.0 - rayUV.x;
		
		samplePos = posFromBuffer(rayUV, getDepth(rayUV));
		
		viewDist  = rayZ / mix(rayEndPos.z, rayStartPos.z, progress);
		depth     = samplePos.z - viewDist;
		
		rayThickness = (uThickness * max(1.0, viewDist/25.0));
		
		if (depth < 0.0 && depth > -rayThickness)
		{
			vis = 1.0;
			progress = progressPrev + ((progress - progressPrev) * 0.5);
		}
		else
		{
			float temp   = progress;
			progress     = progressPrev + ((progress - progressPrev) * 0.5);
			progressPrev = temp;
		}
	}
	
	traceCol = uFallbackColor.rgb;
	
	// Visible, must've hit something.
	if (vis > 0.0)
	{
		vis *= rayVis;
		
		// Bruh
		vis *= (1.0 - clamp(length(samplePos - viewPos) / raySize, 0.0, 1.0));
		
		// Fade based on angle relation to ray
		vec3 hitNormal = getNormal(rayUV);
		if (dot(rayVector, hitNormal) > 0.01)
			vis = 0.0;
		
		// Fade by edge
		vec2 fadeUV = smoothstep(0.2, 0.6, abs(vec2(0.5, 0.5) - rayUV.xy)) * uFadeAmount;
		vis *= clamp(1.0 - (fadeUV.x + fadeUV.y), 0.0, 1.0);
		
		// Clamp
		vis = clamp(vis, 0.0, 1.0);
		
		// Mix in fallback via fresnel if ray hit a reflective surface ¯\_(ツ)_/¯
		vec3 surfCol = mix(texture2D(uDiffuseBuffer, rayUV).rgb, uFallbackColor.rgb, texture2D(uMaterialBuffer, rayUV).r);
		traceCol = mix(traceCol, surfCol, vis);
	}
	
	return traceCol;
}

void main()
{
	vec4 mat, result;
	mat = texture2D(uMaterialBuffer, vTexCoord);
	result = vec4(0.0, 0.0, 0.0, 1.0);
	
	// Perform alpha test to ignore background
	if (texture2D(uDepthBuffer, vTexCoord).a == 0.0)
	{
		if (mat.a == 0.0)
			result = vec4(0.0);
		else
			result = (mat.b > 0.0 ? uFallbackColor : vec4(0.0, 0.0, 0.0, 1.0));
	}
	else
	{
		if (mat.b > 0.0)
			result = vec4(rayTrace(vTexCoord), 1.0);
	}
	
	gl_FragColor = result;
}