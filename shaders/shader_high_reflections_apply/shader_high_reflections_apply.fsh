uniform sampler2D uReflectionsBuffer;

varying vec2 vTexCoord;

void main()
{
	vec3 ref  = texture2D(uReflectionsBuffer, vTexCoord).rgb;
	vec4 base = texture2D(gm_BaseTexture, vTexCoord);
	
	//float lum = 1.0 - max(max(ref.r, ref.g), ref.b);
	//base.rgb *= lum;
	base.rgb += ref.rgb;
	
	gl_FragColor = vec4(base);
}
