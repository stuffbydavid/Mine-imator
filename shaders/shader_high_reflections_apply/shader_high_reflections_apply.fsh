uniform sampler2D uReflectionsBuffer;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uSceneBuffer;

uniform int uGammaCorrect;

varying vec2 vTexCoord;

void main()
{
	vec4 mat = texture2D(uMaterialBuffer, vTexCoord);
	vec4 base = texture2D(gm_BaseTexture, vTexCoord);
	vec3 reflection = vec3(0.0);
	float gamma = (uGammaCorrect > 0 ? 2.2 : 1.0);
	
	base.rgb = pow(base.rgb, vec3(gamma));
	
	if (mat.a > 0.0 && mat.b > 0.0)
	{
		reflection = texture2D(uReflectionsBuffer, vTexCoord).rgb;
		reflection.rgb *= mix(vec3(1.0), texture2D(uSceneBuffer, vTexCoord).rgb, mat.r) * mat.b; // Tint with diffuse depending on metallic value (R)
	}
	
	base.rgb += reflection;
	base.rgb = pow(base.rgb, vec3(1.0/gamma));
	
	gl_FragColor = vec4(base.rgb, base.a);
}
