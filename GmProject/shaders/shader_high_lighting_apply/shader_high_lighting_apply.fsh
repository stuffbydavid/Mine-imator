uniform int uShadowsEnabled;
uniform int uSSAOEnabled;
uniform int uSSAOAlwaysVisible;
uniform int uSpecularEnabled;
uniform sampler2D uShadows;
uniform sampler2D uSSAO;
uniform sampler2D uNormalBuffer;
uniform sampler2D uSpecular;
uniform vec4 uAmbientColor;

uniform sampler2D uMask;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uFogBuffer;
uniform int uFogApply;
uniform int uReflectionsEnabled;
uniform vec4 uFallbackColor;
uniform vec4 uFogColor;
uniform int uFallbackOnly;

uniform float uGamma;
uniform float uBackgroundBrightness;

varying vec2 vTexCoord;

#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_raytrace.FOG_FALLBACK_LIB)

uniform mat4 uProjMatrixInv;

vec3 getReflectionFallback(vec2 uv)
{
	vec3 fallback = pow(uFallbackColor.rgb, vec3(uGamma)) * uBackgroundBrightness;
	vec4 position = uProjMatrixInv * vec4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, 1.0, 1.0);
	vec3 normal = unpackNormal(texture2D(uNormalBuffer, uv));
	vec3 viewDir = normalize(-(position.xyz / position.w));
	vec3 rayDir = reflect(-viewDir, normal);
	float fog = getFogFallback(vec3(0.0), rayDir);
	vec3 fogColor = pow(uFogColor.rgb, vec3(uGamma)) * uBackgroundBrightness;
	return mix(fallback, fogColor, fog);
}

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 matColor = texture2D(uMaterialBuffer, vTexCoord);
	vec3 reflectionFallback = getReflectionFallback(vTexCoord);
	float coverage = baseColor.a;
	baseColor.rgb = coverage > 0.0001 ? baseColor.rgb / coverage : vec3(0.0);
	vec4 litColor = texture2D(uMask, vTexCoord);
	float litCoverage = min(litColor.a, coverage);

	if (uFallbackOnly == 0)
	{
		float unlitCoverage = coverage - litCoverage;
		vec3 unlitColor = max(baseColor.rgb * coverage - litColor.rgb, vec3(0.0));
		unlitColor = unlitCoverage > 0.0001 ? unlitColor / unlitCoverage : vec3(0.0);
		unlitColor = pow(unlitColor, vec3(uGamma)) * uBackgroundBrightness * unlitCoverage;
		baseColor.rgb = litCoverage > 0.0001 ? litColor.rgb / litCoverage : vec3(0.0);
		
		// Apply gamma to base
		baseColor.rgb = pow(baseColor.rgb, vec3(uGamma));
		
		vec3 spec = mix(vec3(1.0), baseColor.rgb, matColor.g) * reflectionFallback * matColor.b;
		
		// Sum up lighting
		vec3 ssao = vec3(1.0);
		if (uSSAOEnabled > 0)
			ssao = texture2D(uSSAO, vTexCoord).rgb;
		
		vec3 ambient = uAmbientColor.rgb;
		if (uSSAOAlwaysVisible == 0)
			ambient *= ssao;
			
		ambient *= (1.0 - matColor.g) * (1.0 - matColor.b);
		
		vec3 diffuse = ambient;
		
		if (uShadowsEnabled > 0)
			diffuse += litCoverage > 0.0001 ? texture2D(uShadows, vTexCoord).rgb / litCoverage : vec3(0.0);
		
		if (uSSAOAlwaysVisible > 0)
			diffuse *= ssao;
		
		if (uShadowsEnabled > 0)
			diffuse += litCoverage > 0.0001 ? texture2D(uFogBuffer, vTexCoord).g / litCoverage : 0.0;
		
		baseColor.rgb *= diffuse;
		
		// If reflections are disabled, add fallback color for fresnel
		if (uReflectionsEnabled == 0)
			baseColor.rgb += spec;
		
		if (uSpecularEnabled > 0)
			baseColor.rgb += litCoverage > 0.0001 ? texture2D(uSpecular, vTexCoord).rgb / litCoverage : vec3(0.0);

		baseColor.rgb = baseColor.rgb * litCoverage + unlitColor;
	}
	else
	{
		vec3 diffuseColor = litCoverage > 0.0001 ? litColor.rgb / litCoverage : vec3(0.0);
		diffuseColor = pow(diffuseColor, vec3(uGamma));
		baseColor.rgb *= coverage;
		baseColor.rgb += mix(vec3(1.0), diffuseColor, matColor.g) * reflectionFallback * matColor.b * litCoverage;
	}
	
	if (uFogApply > 0 && coverage > 0.0001)
	{
		vec3 fogColor = pow(uFogColor.rgb, vec3(uGamma)) * uBackgroundBrightness;
		vec4 fogData = texture2D(uFogBuffer, vTexCoord);
		float fog = fogData.a > 0.0001 ? fogData.r / fogData.a : 0.0;
		baseColor.rgb = mix(baseColor.rgb / coverage, fogColor, fog) * coverage;
	}
	
	gl_FragColor = baseColor;
}
