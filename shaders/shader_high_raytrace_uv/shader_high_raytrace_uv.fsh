varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uNoiseBuffer;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform float uNear;
uniform float uFar;
uniform vec2 uScreenSize;

uniform float uPrecision;
uniform float uThickness;
uniform float uNoiseSize;
uniform int uSpecularRay; // Determines if raytrace is diffuse/specular

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

float linearizeDepth(float depth)
{
	return uNear * uFar / (uFar + depth * (uNear - uFar));
}

// Reconstruct a position from a screen space coordinate and (linear) depth
vec3 posFromBuffer(vec2 coord, float depth)
{
	vec4 pos = uProjMatrixInv * vec4(coord.x * 2.0 - 1.0, 1.0 - coord.y * 2.0, transformDepth(depth), 1.0);
	return pos.xyz / pos.w;
}

float unpackFloat2(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

vec2 packFloat2(float f)
{
	return vec2(floor(f / 255.0) / 255.0, fract(f / 255.0));
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
	vec4 coord	= (uProjMatrix * viewPos);
	coord.xy	= (coord.xy / coord.w) * 0.5 + 0.5;
	coord.y		= 1.0 - coord.y;
	coord.xy	*= uScreenSize;
	
	return coord.xy;
}

vec3 unpackNormalBlueNoise(vec4 c)
{
	return normalize(vec3(cos(c.r * 360.0), sin(c.r * 360.0), c.g));
}

// Ray tracer, returns hit coordinate
vec2 rayTrace(vec2 originUV)
{
	vec3 traceCol = vec3(0.0);
	
	// Material from UV
	vec3 mat = texture2D(uMaterialBuffer, originUV).rgb;
	
	// Sample buffers
	float originDepth	= getDepth(originUV);
	vec3 viewPos		= posFromBuffer(originUV, originDepth);
	vec3 normal			= normalize(getNormal(originUV));
	
	// Calculate ray direction from surface normal
	vec3 rayVector;
	
	vec2 noiseScale = uScreenSize / uNoiseSize;
	vec3 randVec	= unpackNormalBlueNoise(texture2D(uNoiseBuffer, vTexCoord * noiseScale));
	
	// Construct kernel basis matrix
	vec3 tangent		= normalize(randVec - normal * dot(randVec, normal));
	vec3 bitangent		= cross(normal, tangent);
	mat3 kernelBasis	= mat3(tangent, bitangent, normal);
	
	vec3 kernel			= texture2D(uNoiseBuffer, vTexCoord * noiseScale).rgb;//normalize(texture2D(uNoiseBuffer, vTexCoord * noiseScale).rgb);
	kernel.rg			= (kernel.rg * 2.0) - 1.0;
	kernel				= normalize(kernel) * 0.1;
	
	if (uSpecularRay == 1) // Reflection ray
	{
		rayVector = normalize(reflect(normalize(viewPos), normalize(normal + (kernelBasis * kernel * mat.g))));
	}
	else // Indirect ray
	{
		rayVector = normalize(kernelBasis * kernel);
		
		if (dot(rayVector, normal) <= 0.0)
			rayVector = normalize(-rayVector);
	}
	
	// Pixel coord on texture
	vec2 pixelCoord     = uScreenSize / originUV;
	
	// Ray data
	float raySize       = 8000.0;
	vec4 rayStartPos    = vec4(viewPos, 1.0);
	vec4 rayEndPos      = vec4(rayStartPos.xyz + (rayVector * raySize), 1.0);
	
	// Clip to near camera plane
	if (rayEndPos.z < uNear)
		rayEndPos.xyz	= rayStartPos.xyz + (rayVector * (rayStartPos.z - uNear));
	
	vec2 rayStartPixel  = viewPosToPixel(rayStartPos);
	vec2 rayEndPixel    = viewPosToPixel(rayEndPos);
	vec2 rayPixel       = rayStartPixel;
	vec2 rayUV          = rayPixel / uScreenSize;
	float rayDistance	= 0.0;
	bool rayHit			= false;
	
	// Trace data
	vec2 pixelDelta     = rayEndPixel - rayStartPixel;
	bool useDeltaX      = (abs(pixelDelta.x) >= abs(pixelDelta.y));
	float stepDelta     = (useDeltaX ? abs(pixelDelta.x) : abs(pixelDelta.y)) * clamp(uPrecision, 0.0, 1.0);
	vec2 pixelStepDelta = pixelDelta / max(stepDelta, 0.001);
	vec3 samplePos      = viewPos;
	
	float progress, progressPrev;
	progress		= 0.0;
	progressPrev	= 0.0;
	
	float viewDist     = originDepth;
	float depth        = uThickness;
	float depthPrev;
	
	float rayThickness = uThickness;
	int traceSteps     = int(stepDelta);
	
	float rayZ = (rayStartPos.z * rayEndPos.z);
	
	for (int i = 0; i < traceSteps; i++)
	{
		progressPrev = progress;
		depthPrev	 = depth;
		
		rayPixel += pixelStepDelta;
		rayUV     = rayPixel / uScreenSize;
		
		samplePos = posFromBuffer(rayUV, getDepth(rayUV));
		
		progress  = (useDeltaX ?
					((rayPixel.x - rayStartPixel.x) / pixelDelta.x) :
					((rayPixel.y - rayStartPixel.y) / pixelDelta.y));
		
		progress  = clamp(progress, 0.0, 1.0);
		
		viewDist  = rayZ / mix(rayEndPos.z, rayStartPos.z, progress);
		depth     = viewDist - samplePos.z;
		
		if (rayUV.x <= 0.0 || rayUV.y <= 0.0 || rayUV.x >= 1.0 || rayUV.y >= 1.0)
			break;
		
		// Check for collision
		if (depth > 0.0 && dot(normal, getNormal(rayUV)) < .99)
		{
			rayDistance = length(mix(rayStartPos, rayEndPos, progress) - rayStartPos);
			rayThickness = (uThickness * rayDistance);
			
			// Is the ray in the object?
			if (depth < rayThickness)
				rayHit = true;
			
			break;
		}
	}
	
	// Discard if ray hit a backface (Works sometimes?)
	if (depthPrev > uThickness)
		rayHit = false;
	
	if (!rayHit || texture2D(uDepthBuffer, rayUV).a < 1.0)
		return vec2(1.0);
	
	// Refine ray UV
	const int refineSteps = 10;
	
	progress = progressPrev + ((progress - progressPrev) * 0.5);
	
	for (int i = 0; i < refineSteps; i++)
	{
		rayPixel  = mix(rayStartPixel, rayEndPixel, progress);
		rayUV     = rayPixel / uScreenSize;
		
		samplePos = posFromBuffer(rayUV, getDepth(rayUV));
		
		viewDist  = rayZ / mix(rayEndPos.z, rayStartPos.z, progress);
		depth     = viewDist - samplePos.z;
		
		rayDistance = length(mix(rayStartPos, rayEndPos, progress) - rayStartPos);
		rayThickness = (uThickness * rayDistance);
		
		if (depth > 0.0 && depth < rayThickness)
		{
			progress = progressPrev + ((progress - progressPrev) * 0.5);
		}
		else
		{
			float temp   = progress;
			progress     = progressPrev + ((progress - progressPrev) * 0.5);
			progressPrev = temp;
		}
	}
	
	return rayUV;
}

void main()
{
	// Full ray coord defaults to no hit in resolve
	vec2 rayHit = vec2(1.0);
	
	// Depth test
	if (texture2D(uDepthBuffer, vTexCoord).a > 0.0)
	{
		if (uSpecularRay == 1) // Reflection ray
		{
			vec4 mat = texture2D(uMaterialBuffer, vTexCoord);
		
			if (mat.g < .75 && mat.b > 0.0)
				rayHit = rayTrace(vTexCoord);
		}
		else // Indirect ray
			rayHit = rayTrace(vTexCoord);
	}
	
	vec4 rayPacked = vec4(packFloat2(rayHit.x * (255.0 * 255.0)), packFloat2(rayHit.y * (255.0 * 255.0)));
	
	if (rayHit.x == 1.0)
		rayPacked = vec4(1.0);
	
	gl_FragData[0] = vec4(rayPacked.rg, 0.0, 1.0);
	gl_FragData[1] = vec4(rayPacked.ba, 0.0, 1.0);
}