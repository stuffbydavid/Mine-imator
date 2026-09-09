varying vec2 vTexCoord;

uniform sampler2D uNormalBuffer;
uniform sampler2D uLightBuffer;
uniform float uGamma;

void main()
{
	vec3 directLight = texture2D(uLightBuffer, vTexCoord).rgb;
	float emissive = texture2D(uNormalBuffer, vTexCoord).a;
	vec3 diffuse = pow(texture2D(gm_BaseTexture, vTexCoord).rgb, vec3(uGamma));
	
	gl_FragColor = vec4((directLight + vec3(emissive)) * diffuse, 1.0);
}
