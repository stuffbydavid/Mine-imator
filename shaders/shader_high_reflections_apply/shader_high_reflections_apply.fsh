uniform sampler2D uReflectionsBuffer;
uniform sampler2D uMaterialBuffer;

uniform vec2 uScreenSize;
uniform int uHalfRes;

varying vec2 vTexCoord;

vec4 getReflection(vec2 uv)
{
	float fresnel = texture2D(uMaterialBuffer, uv).b;
	return vec4(texture2D(uReflectionsBuffer, uv).rgb * fresnel, fresnel);
}

void main()
{
	vec4 mat = texture2D(uMaterialBuffer, vTexCoord);
	vec4 base = texture2D(gm_BaseTexture, vTexCoord);
	
	if (mat.a > 0.0)
	{
		if (uHalfRes > 0)
		{
			if (mat.b > 0.0)
			{
				//vec3 fresnel = texture2D(uMaterialBuffer, vTexCoord).b;
				vec2 tex  = 1.0 / uScreenSize;
			
				vec4 refCol = vec4(0.0);
				refCol += getReflection(vTexCoord + vec2(tex.x,  0.0));
				refCol += getReflection(vTexCoord + vec2(0.0,  tex.y));
				refCol += getReflection(vTexCoord + vec2(-tex.x, 0.0));
				refCol += getReflection(vTexCoord + vec2(0.0, -tex.y));
			
				if (refCol.a != 0.0)
					refCol.rgb /= refCol.a;
			
				base.rgb += (refCol.rgb * mat.b);
			}
		}
		else
			base.rgb += texture2D(uReflectionsBuffer, vTexCoord).rgb * mat.b;
	}
	
	gl_FragColor = vec4(base);
}
