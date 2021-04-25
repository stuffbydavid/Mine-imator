#define MAXSTEPS 500
#define MAXRAYS 16

varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uLightingBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;
uniform sampler2D uBrightnessBuffer;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform mat4 uViewMatrix;
uniform mat4 uViewMatrixInv;
uniform float uNear;
uniform float uFar;

uniform vec3 uKernel[MAXRAYS];
uniform float uOffset[MAXRAYS];
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

// Update screen position and UV coordinate based on ray position
bool updateCoord(inout vec4 projectedCoord, inout vec2 screenCoord, inout vec3 screenPos, vec3 rayPos)
{
	projectedCoord = uProjMatrix * vec4(rayPos, 1.0);
	screenCoord = (projectedCoord.xy / projectedCoord.w) * 0.5 + 0.5;
	
	if (screenCoord.x < 0.0 || screenCoord.x > 1.0 || screenCoord.y < 0.0 || screenCoord.y > 1.0)
		return false;
	
	screenCoord.y = 1.0 - screenCoord.y;
	screenPos = posFromBuffer(screenCoord, getDepth(screenCoord));
	
	return true;
}

// Casts ray from camera for n amount of steps given a step amount and direction
void rayTrace(int sample, vec3 direction, vec3 rayPos, float bias, inout vec3 giColor)
{
	vec4 projectedCoord;
	vec2 screenCoord;
	
	float dDepth = -1.0;
	int steps = 0;
	
	vec3 startPos = rayPos;
	vec3 screenPos = vec3(rayPos);
	
	direction *= uStepSize;
	rayPos += direction * uOffset[sample];
	
	// Trace ray steps
	for (int i = 0; i < MAXSTEPS; i++)
	{
		// Move ray position in direction
		rayPos += direction;
		
		// Update 2D/3D coordinates
		if (!updateCoord(projectedCoord, screenCoord, screenPos, rayPos))
			break;
		
		// Check for collision
		if (screenPos.z <= (rayPos.z - bias))
		{
			// Refine ray position
			for (int i = 0; i < 10; i++)
			{
				// Update 2D/3D coordinates
				if (!updateCoord(projectedCoord, screenCoord, screenPos, rayPos))
					break;
				
				dDepth = screenPos.z - rayPos.z;
				
				direction *= 0.5;
				if (dDepth > 0.0)
					rayPos += direction;
				else
					rayPos -= direction;
			}
			
			// Get final screen position
			rayPos += direction;
			
			// Update 2D/3D coordinates
			if (!updateCoord(projectedCoord, screenCoord, screenPos, rayPos))
				break;
			
			// Check if surface is emmisive, if not, check for diffuse angle
			float dif = 1.0;
			float falloff = 1.0;
			
			if (texture2D(uBrightnessBuffer, screenCoord).r < 0.001)
			{
				vec3 rayDir = normalize(startPos - screenPos);
				vec3 sampleNormal = normalize(getNormal(screenCoord));
				
				dif = max(0.0, dot(sampleNormal, rayDir));
			}
			else
			{
				// Check if sampled surface is within reasible range
				float dis = clamp(abs(distance(screenPos, startPos)), 0.0, (float(uStepAmount) * uStepSize));
				falloff = 1.0 - pow(clamp((dis / (float(uStepAmount) * uStepSize)), 0.0, 1.0), 2.0);
			}
			
			vec3 light = texture2D(uDiffuseBuffer, screenCoord).rgb * texture2D(uLightingBuffer, screenCoord).rgb;
			giColor += light * falloff * dif;
			return;
		}
		
		// Break loop if steps reach max
		if (steps > uStepAmount)
			break;
		
		steps++;
	}
}

void main()
{
	// Perform alpha test to ignore background
	if (texture2D(uDepthBuffer, vTexCoord).a < 1.0)
		discard;
	
	// Sample buffers
	float originDepth = getDepth(vTexCoord);
	vec3 viewPos = posFromBuffer(vTexCoord, originDepth);
	vec3 worldPos = vec3(vec4(viewPos, 1.0) * uViewMatrixInv);
	
	// Get normal
	vec3 normal = getNormal(vTexCoord);
	
	// RT collision bias
	float bias = originDepth * 200.0;
	
	// Construct kernel basis matrix
	vec3 randVec = ((vec3(hash(worldPos)) - 0.5) * 2.0);
	vec3 tangent = normalize(randVec - normal * dot(randVec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 kernelBasis = mat3(tangent, bitangent, normal);
	
	// Sample rays
	vec3 giColor = vec3(0.0);
	
	for (int i = 0; i < MAXRAYS; i++)
	{
		// Get ray direction
		vec3 rayDir = normalize(kernelBasis * uKernel[i]);
		rayTrace(i, rayDir, viewPos, bias, giColor);
		
		if (i >= uRays)
			break;
	}
	
	giColor /= float(uRays);
	gl_FragColor = vec4(giColor, 1.0);
}