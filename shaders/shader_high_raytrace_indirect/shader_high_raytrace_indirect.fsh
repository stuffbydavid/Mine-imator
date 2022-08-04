varying vec2 vTexCoord;

// Buffers
uniform sampler2D uRaytraceBuffer;
uniform sampler2D uRaytrace2Buffer;
uniform sampler2D uLightingBuffer;
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;
uniform sampler2D uDepthBuffer;

uniform float uNear;
uniform float uFar;
uniform mat4 uProjMatrixInv;

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

void main()
{
	vec3 giColor = vec3(0.0);
	
	// Get ray coord
	vec4 rtCoord = vec4(texture2D(uRaytraceBuffer, vTexCoord).rg, texture2D(uRaytrace2Buffer, vTexCoord).rg);
	
	// Full X/Y UV, no hit
	if (rtCoord.r == 1.0)
		discard;
	
	vec2 rayUV = vec2(unpackFloat2(rtCoord.r, rtCoord.g), unpackFloat2(rtCoord.b, rtCoord.a)) / (255.0 * 255.0);
	
	// Get origin/hit normal
	vec3 originNormal = getNormal(vTexCoord);
	vec3 hitNormal    = getNormal(rayUV);
	
	// Reconstruct ray direction from view positions
	vec3 originPos = posFromBuffer(vTexCoord, getDepth(vTexCoord));
	vec3 hitPos = posFromBuffer(rayUV, getDepth(rayUV));
	vec3 rayDir = normalize(hitPos - originPos);
	float dif = max(0.0, dot(-hitNormal, rayDir));
	
	giColor = (texture2D(uLightingBuffer, rayUV).rgb * dif) * texture2D(uDiffuseBuffer, rayUV).rgb;
	
	gl_FragColor = vec4(giColor, 1.0);
}