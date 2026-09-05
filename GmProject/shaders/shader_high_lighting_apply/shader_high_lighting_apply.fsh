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
uniform int uReflectionsEnabled;
uniform vec4 uFallbackColor;

uniform float uGamma;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	float mask = texture2D(uMask, vTexCoord).r;
	
	// Apply gamma to base
	baseColor.rgb = pow(baseColor.rgb, mix(vec3(1.0), vec3(uGamma), mask));
	
	vec4 matColor = texture2D(uMaterialBuffer, vTexCoord); // G = metallic, B = fresnel
	vec3 spec = mix(vec3(1.0), baseColor.rgb, matColor.g) * pow(uFallbackColor.rgb, vec3(uGamma)) * matColor.b;
	
	// Sum up lighting
	vec3 ssao = vec3(1.0);
	if (uSSAOEnabled > 0)
		ssao = texture2D(uSSAO, vTexCoord).rgb;
	
	vec3 ambient = uAmbientColor.rgb;
	if (uSSAOAlwaysVisible == 0)
		ambient *= ssao;
	
	vec3 diffuse = ambient;
	
	if (uShadowsEnabled > 0)
		diffuse += texture2D(uShadows, vTexCoord).rgb;
	
	if (uSSAOAlwaysVisible > 0)
		diffuse *= ssao;
	
	// Reduce diffuse based on Metallic
	diffuse *= (1.0 - matColor.g);
	
	// "Energy conservation", remove diffuse based on fresnel
	diffuse *= (1.0 - matColor.b);
	
	// Add emissive
	if (uShadowsEnabled > 0)
		diffuse += texture2D(uEmissive, vTexCoord).a;
	
	baseColor.rgb *= mix(vec3(1.0), diffuse, mask);
	
	// If reflections are disabled, add fallback color for fresnel
	if (uReflectionsEnabled == 0)
		baseColor.rgb += spec;
	
	if (uSpecularEnabled > 0)
		baseColor.rgb += texture2D(uSpecular, vTexCoord).rgb;
	
	gl_FragColor = baseColor;
}
