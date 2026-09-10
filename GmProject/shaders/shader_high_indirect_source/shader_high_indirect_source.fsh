varying vec2 vTexCoord;

uniform sampler2D uNormalBuffer;
uniform sampler2D uLightBuffer;
uniform sampler2D uPreviousBuffer;
uniform float uPreviousAmount;
uniform float uGamma;

void main()
{
	vec3 directLight = texture2D(uLightBuffer, vTexCoord).rgb;
	vec3 previousLight = texture2D(uPreviousBuffer, vTexCoord).rgb * uPreviousAmount;
	float emissive = texture2D(uNormalBuffer, vTexCoord).a;
	vec3 diffuse = pow(texture2D(gm_BaseTexture, vTexCoord).rgb, vec3(uGamma));
	
	gl_FragColor = vec4((directLight + previousLight + vec3(emissive)) * diffuse, 1.0);
}
