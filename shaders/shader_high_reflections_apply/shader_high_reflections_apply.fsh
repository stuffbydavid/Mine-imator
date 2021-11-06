uniform sampler2D uReflectionsBuffer;
uniform sampler2D uMaterialBuffer;
uniform sampler2D uDiffuseBuffer;

varying vec2 vTexCoord;

void main()
{
	vec4 mat = texture2D(uMaterialBuffer, vTexCoord);
	vec4 base = texture2D(gm_BaseTexture, vTexCoord);
	vec3 reflection = vec3(0.0);
	
	if (mat.a > 0.0 && mat.b > 0.0)
	{
		reflection = texture2D(uReflectionsBuffer, vTexCoord).rgb;
		reflection.rgb *= mix(vec3(1.0), texture2D(uDiffuseBuffer, vTexCoord).rgb, mat.r) * mat.b; // Tint with diffuse depending on metallic value (R)
	}
	
	gl_FragColor = vec4(base.rgb + reflection, base.a);
}
