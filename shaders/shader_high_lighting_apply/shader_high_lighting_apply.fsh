uniform int uSSAOEnabled;
uniform sampler2D uSSAO;

uniform int uShadowsEnabled;
uniform sampler2D uShadows;

uniform sampler2D uIndirect;
uniform int uIndirectEnabled;
uniform float uIndirectStrength;

uniform sampler2D uMask;
uniform sampler2D uMaterialBuffer;
uniform int uReflectionsEnabled;
uniform vec4 uFallbackColor;

uniform vec4 uAmbientColor;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 matColor = texture2D(uMaterialBuffer, vTexCoord);
	
	// Sum up lighting
	vec3 diffuse = vec3(1.0);
	
	if (uShadowsEnabled > 0)
	{
		vec3 direct = texture2D(uShadows, vTexCoord).rgb;
		vec3 indirect = vec3(0.0);
		
		// Calculate indirect
		if (uIndirectEnabled > 0)
			indirect = texture2D(uIndirect, vTexCoord).rgb * uIndirectStrength;
		
		diffuse = uAmbientColor.rgb + direct + indirect;
	}
	
	// Multiply light and ao with diffuse
	diffuse *= 1.0 - matColor.r;
	
	// "Energy conservation", remove diffuse based on fresnel
	diffuse *= 1.0 - matColor.b;
	
	baseColor.rgb *= mix(vec3(1.0), diffuse, texture2D(uMask, vTexCoord).rgb);
	
	if (uSSAOEnabled > 0)
		baseColor.rgb *= texture2D(uSSAO, vTexCoord).rgb;
	
	// If reflections are disabled, add fallback color for fresnel
	if (uReflectionsEnabled == 0)
		baseColor.rgb += uFallbackColor.rgb * matColor.b;
	
	gl_FragColor = baseColor;
}
