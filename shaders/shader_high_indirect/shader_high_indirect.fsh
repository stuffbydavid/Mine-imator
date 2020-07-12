#define MAXSTEPS 500
#define MAXRAYS 16

varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uLightingBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform mat4 uViewMatrix;
uniform mat4 uViewMatrixInv;
uniform float uNear;
uniform float uFar;

uniform vec3 uKernel[MAXRAYS];
uniform float uStepSize;
uniform int uStepAmount;
uniform int uRays;

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
vec3 posFromBuffer(vec2 coord, float depth)
{
	vec4 pos = uProjMatrixInv * vec4(coord.x * 2.0 - 1.0, 1.0 - coord.y * 2.0, transformDepth(depth), 1.0);
	return pos.xyz / pos.w;
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

float lightFalloff(float dis, float radius)
{
	return pow(clamp(1.0 - pow(dis/radius, 4.0), 0.0, 1.0), 2.0) / (pow(dis, 2.0) + 1.0);
}

// Hash scatter function
#define SCALE vec3(.8, .8, .8)
#define K 19.19

vec3 hash(vec3 a)
{
	a = fract(a * SCALE);
	a += dot(a, a.yxz + K);
	return fract((a.xxy + a.yxx) * a.zyx);
}

// Casts ray from camera for n amount of steps given a step amount and direction
vec2 rayTrace(vec3 direction, inout vec3 rayPos, out float dDepth)
{
	direction *= uStepSize;
	
	vec3 startPos = rayPos;
	vec3 screenPos = vec3(rayPos);
	int steps = 0;
	vec4 projectedCoord;
	vec2 screenCoord = vec2(1.0);
	
	float bias = getDepth(vTexCoord) * 50.0;
	
	for (int i = 0; i < MAXSTEPS; i++)
	{
		rayPos += direction;
		
		projectedCoord = uProjMatrix * vec4(rayPos, 1.0);
		screenCoord = (projectedCoord.xy / projectedCoord.w) * 0.5 + 0.5;
		
		if (screenCoord.x < 0.0 || screenCoord.x > 1.0 || screenCoord.y < 0.0 || screenCoord.y > 1.0)
			break;
		
		screenCoord.y = 1.0 - screenCoord.y;
		screenPos = posFromBuffer(screenCoord, getDepth(screenCoord));
		
		dDepth = screenPos.z - rayPos.z;
		
		// Check distance bias
		if (screenPos.z <= (rayPos.z - bias))
		{
			// Check if sampled surface is within reasible range
			bool rangeCheck = (abs(dDepth) < (float(uStepAmount) * uStepSize));
			
			// Check if sampled surface can realistically bounce light onto origin surface
			bool bounceCheck = (max(0.0, dot(direction, getNormal(screenCoord))) < 1.0);
			
			// Collision check based on view Z-direction of ray
			if (rangeCheck && bounceCheck)
			{
				if (direction.z > 0.0)
				{
					// Don't need to worry about surface being occluded
					if (startPos.z < screenPos.z)
						return screenCoord;
				}
				else
				{
					if (startPos.z > screenPos.z)
						return screenCoord;
				}
			}
		}
		
		// Break loop if steps reach max
		if (steps > uStepAmount)
		{
			dDepth = 1.0;
			break;
		}
		
		steps++;
	}
	
	dDepth = 1.0;
	return screenCoord;
}

void main()
{
	// Sample buffers
	vec3 viewPos = posFromBuffer(vTexCoord, getDepth(vTexCoord));
	vec3 normal = getNormal(vTexCoord);
	
	vec3 wp = vec3(vec4(viewPos, 1.0) * uViewMatrixInv);
	
	vec3 rayPos = viewPos;
	
	vec2 coords = vec2(0.0);
	float dDepth = -1.0;
	
	vec4 giColor = vec4(0.0, 0.0, 0.0, 0.0);
	
	// Only do reflections on visible surfaces
	vec3 randVec = ((vec3(hash(wp)) - 0.5) * 2.0);
	
	// Construct kernel basis matrix
	vec3 tangent = normalize(randVec - normal * dot(randVec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 kernelBasis = mat3(tangent, bitangent, normal);
	
	// Sample rays
	for (int i = 0; i < MAXRAYS; i++)
	{
		rayPos = viewPos;
		dDepth = -1.0;
		
		// Get ray direction
		vec3 rayDir = normalize(kernelBasis * uKernel[i]);
		
		coords = rayTrace(rayDir, rayPos, dDepth);
		
		if (dDepth <= 0.0)
		{
			vec3 light = (texture2D(uLightingBuffer, coords).rgb * texture2D(uDiffuseBuffer, coords).rgb);
			giColor.rgb += light;
		}
		
		if (i >= uRays)
			break;
	}
	
	giColor.rgb /= float(uRays);
	
	gl_FragColor = giColor;
	gl_FragColor.a = 1.0;
}