varying vec2 vTexCoord;

// Buffers
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uRaytraceBuffer;
uniform sampler2D uRaytrace2Buffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNormalBufferExp;
uniform sampler2D uDepthBuffer;
uniform sampler2D uMaterialBuffer;

uniform float uNear;
uniform float uFar;
uniform mat4 uProjMatrixInv;

uniform float uFadeAmount;
uniform vec4 uFallbackColor;

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
	vec3 refColor = uFallbackColor.rgb;
	
	// Get ray coord
	vec4 rtCoord = vec4(texture2D(uRaytraceBuffer, vTexCoord).rg, texture2D(uRaytrace2Buffer, vTexCoord).rg);
	vec2 rayUV = vec2(unpackFloat2(rtCoord.r, rtCoord.g), unpackFloat2(rtCoord.b, rtCoord.a)) / (255.0 * 255.0);
	
	// Get origin/hit normal
	vec3 originNormal = getNormal(vTexCoord);
	vec3 hitNormal    = getNormal(rayUV);
	
	// Reconstruct ray direction from view positions
	vec3 originPos = posFromBuffer(vTexCoord, getDepth(vTexCoord));
	vec3 hitPos = posFromBuffer(rayUV, getDepth(rayUV));
	vec3 rayDir = normalize(hitPos - originPos);
	float dif = max(0.0, dot(-hitNormal, rayDir));
	
	// Full X/Y UV, no hit
	if (rtCoord.r < 1.0)
	{
		// Bruh
		float vis = 1.0;//(1.0 - clamp(length(hitPos - originPos) / abs(hitPos.z - originPos.z), 0.0, 1.0));
		
		// Fade by edge
		vec2 fadeUV = smoothstep(0.2, 0.6, abs(vec2(0.5, 0.5) - rayUV.xy)) * uFadeAmount;
		vis *= clamp(1.0 - (fadeUV.x + fadeUV.y), 0.0, 1.0);
		
		// Clamp
		vis = clamp(vis, 0.0, 1.0);
		
		// Mix in fallback via fresnel if ray hit a reflective surface ¯\_(ツ)_/¯
		vec3 surfCol = mix(texture2D(uDiffuseBuffer, rayUV).rgb, uFallbackColor.rgb, texture2D(uMaterialBuffer, rayUV).r);
		refColor = mix(refColor, surfCol, vis);
	}
	
	//if (vTexCoord.x > 0.0)
	//	refColor = uFallbackColor.rgb;
	
	gl_FragColor = vec4(refColor, 1.0);
}