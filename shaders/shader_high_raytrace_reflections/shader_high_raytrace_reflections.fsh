varying vec2 vTexCoord;

// Buffers
uniform sampler2D uSceneBuffer;
uniform sampler2D uDiffuseBuffer;
uniform sampler2D uRaytraceBuffer;
uniform sampler2D uRaytrace2Buffer;
uniform sampler2D uMaterialBuffer;

uniform float uNear;
uniform float uFar;
uniform mat4 uProjMatrixInv;

uniform float uFadeAmount;
uniform vec4 uFallbackColor;

uniform int uGammaCorrect;

float unpackFloat2(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

float percent(float xx, float start, float end)
{
	return clamp((xx - start) / (end - start), 0.0, 1.0);
}

void main()
{
	float gamma = (uGammaCorrect > 0 ? 2.2 : 1.0);
	vec3 refColor = pow(uFallbackColor.rgb, vec3(gamma));
	
	// Get ray coord
	vec4 rtCoord = vec4(texture2D(uRaytraceBuffer, vTexCoord).rg, texture2D(uRaytrace2Buffer, vTexCoord).rg);
	vec2 rayUV = vec2(unpackFloat2(rtCoord.r, rtCoord.g), unpackFloat2(rtCoord.b, rtCoord.a)) / (255.0 * 255.0);
	
	// Full X/Y UV, no hit
	if (rtCoord.r < 1.0)
	{
		// Sample materials
		vec3 rayMat = texture2D(uMaterialBuffer, rayUV).rgb;
		vec3 originMat = texture2D(uMaterialBuffer, vTexCoord).rgb;
		
		// Fade by edge
		vec2 fadeUV = smoothstep(0.2, 0.6, abs(vec2(0.5, 0.5) - rayUV.xy)) * uFadeAmount;
		float vis = clamp(1.0 - (fadeUV.x + fadeUV.y), 0.0, 1.0);
		
		// Fade if roughness is too high
		vis *= 1.0 - percent(originMat.g, .85, .95);
		
		// Clamp
		vis = clamp(vis, 0.0, 1.0);
		
		float metallic = rayMat.r * vis;
		
		if (metallic > 0.0)
			refColor *= mix(vec3(1.0), pow(texture2D(uDiffuseBuffer, rayUV).rgb, vec3(gamma)), metallic);
		
		// Mix in fallback via fresnel if ray hit a reflective surface ¯\_(ツ)_/¯
		vec3 surfCol = mix(pow(texture2D(uSceneBuffer, rayUV).rgb, vec3(gamma)), refColor, rayMat.r);
		refColor = mix(refColor, surfCol, vis);
	}
	
	gl_FragColor = vec4(refColor, 1.0);
}