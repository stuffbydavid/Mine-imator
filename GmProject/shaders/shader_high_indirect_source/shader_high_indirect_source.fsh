varying vec2 vTexCoord;

uniform sampler2D uEmissive;
uniform sampler2D uLightBuffer;
uniform sampler2D uPreviousBuffer;
uniform float uPreviousAmount;
uniform float uGamma;

void main()
{
	vec3 directLight = texture2D(uLightBuffer, vTexCoord).rgb;
	vec3 previousLight = texture2D(uPreviousBuffer, vTexCoord).rgb * uPreviousAmount;
	float emissive = texture2D(uEmissive, vTexCoord).g;
	vec4 litColor = texture2D(gm_BaseTexture, vTexCoord);
	vec3 diffuse = litColor.a > 0.0001 ? litColor.rgb / litColor.a : vec3(0.0);
	diffuse = pow(diffuse, vec3(uGamma));
	
	gl_FragColor = vec4((directLight + previousLight * litColor.a + vec3(emissive)) * diffuse, 1.0);
}
