uniform sampler2D uReflectionsBuffer;
uniform sampler2D uMaterialBuffer;

uniform vec2 uScreenSize;

varying vec2 vTexCoord;

vec4 getReflection(vec2 uv)
{
	float fresnel = texture2D(uMaterialBuffer, uv).b;
	return vec4(texture2D(uReflectionsBuffer, uv).rgb * fresnel, fresnel);
}

void main()
{
	vec3 mat  = texture2D(uMaterialBuffer, vTexCoord).rgb;
	vec4 base = texture2D(gm_BaseTexture, vTexCoord);
	
	if (mat.b > 0.0)
	{
		vec3 ref  = texture2D(uReflectionsBuffer, vTexCoord).rgb;
		vec2 tex  = 1.0 / uScreenSize;
		
		vec4 refCol = vec4(0.0);
		refCol += getReflection(vTexCoord + vec2(tex.x, 0.0));
		refCol += getReflection(vTexCoord + vec2(0.0, tex.y));
		refCol += getReflection(vTexCoord + vec2(-tex.x, 0.0));
		refCol += getReflection(vTexCoord + vec2(0.0, -tex.y));
		
		if (refCol.a != 0.0)
			refCol.rgb /= refCol.a;
		
		base.rgb += (refCol.rgb * mat.b);
	}
	
	gl_FragColor = vec4(base);
}
