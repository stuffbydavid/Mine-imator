uniform int uSSAOEnabled;
uniform sampler2D uSSAO;

uniform int uShadowsEnabled;
uniform sampler2D uShadows;

uniform sampler2D uIndirect;
uniform int uIndirectEnabled;
uniform float uIndirectStrength;

uniform sampler2D uMask;

uniform vec4 uAmbientColor;


varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	// Sum up lighting
	vec3 light = vec3(1.0);
	
	if (uShadowsEnabled > 0)
	{
		light = uAmbientColor.rgb;
		light += texture2D(uShadows, vTexCoord).rgb;
		
		if (uIndirectEnabled > 0)
			light += texture2D(uIndirect, vTexCoord).rgb * uIndirectStrength;
	}
	
	// Multiply light and ao with diffuse
	baseColor.rgb *= mix(vec3(1.0), light, texture2D(uMask, vTexCoord).rgb);
	
	if (uSSAOEnabled > 0)
		baseColor.rgb *= texture2D(uSSAO, vTexCoord).rgb;
	
	gl_FragColor = baseColor;
}
