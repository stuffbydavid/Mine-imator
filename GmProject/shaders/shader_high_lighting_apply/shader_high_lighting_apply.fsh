uniform int uShadowsEnabled;
uniform int uSSAOEnabled;
uniform int uSSAOAlwaysVisible;
uniform int uSpecularEnabled;
uniform sampler2D uShadows;
uniform sampler2D uSSAO;
uniform sampler2D uEmissive;
uniform sampler2D uSpecular;
uniform vec4 uAmbientColor;

uniform sampler2D uMask;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uDiffuseBuffer;
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
	vec3 normal = unpackNormal(texture2D(uEmissive, uv));
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

	if (uFallbackOnly == 0)
	{
		float mask = texture2D(uMask, vTexCoord).r;
		
		// Apply gamma to base
		baseColor.rgb = pow(baseColor.rgb, vec3(uGamma));
		baseColor.rgb *= mix(uBackgroundBrightness, 1.0, mask);
		
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
			diffuse += texture2D(uShadows, vTexCoord).rgb;
		
		if (uSSAOAlwaysVisible > 0)
			diffuse *= ssao;
		
		// Add emissive
		if (uShadowsEnabled > 0)
			diffuse += texture2D(uEmissive, vTexCoord).a;
		
		baseColor.rgb *= mix(vec3(1.0), diffuse, mask);
		
		// If reflections are disabled, add fallback color for fresnel
		if (uReflectionsEnabled == 0)
			baseColor.rgb += spec;
		
		if (uSpecularEnabled > 0)
			baseColor.rgb += texture2D(uSpecular, vTexCoord).rgb;
	}
	else
	{
		vec3 diffuseColor = pow(texture2D(uDiffuseBuffer, vTexCoord).rgb, vec3(uGamma));
		baseColor.rgb += mix(vec3(1.0), diffuseColor, matColor.g) * reflectionFallback * matColor.b;
	}
	
	gl_FragColor = baseColor;
}
