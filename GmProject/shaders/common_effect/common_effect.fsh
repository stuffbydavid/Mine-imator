#pragma shady: skip_compilation
void main(){}

#region EFFECT_GLINT_LIB
#pragma shady: macro_begin EFFECT_GLINT_LIB

uniform sampler2D uGlintTexture; // static
uniform vec2 uGlintOffset;
uniform vec2 uGlintSize;
uniform int uGlintEnabled;
uniform float uGlintStrength;

vec3 getGlint(vec4 col, vec2 texCoord, vec2 texSize, float uGamma)
{
	if (uGlintEnabled > 0 && col.a > 0.0)
		return pow(texture2D(uGlintTexture, (texCoord * ((texSize / uGlintSize))) + uGlintOffset).rgb * col.a * uGlintStrength, vec3(uGamma));
	else
		return vec3(0.0);
}

#pragma shady: macro_end
#endregion

#region EFFECT_FOG_LIB
#pragma shady: macro_begin EFFECT_FOG_LIB

uniform int uFogShow;
uniform vec4 uFogColor; // static
uniform float uFogDistance; // static
uniform float uFogSize; // static
uniform float uFogHeight; // static

float getFog(vec3 pos, vec3 camPos)
{
	float fog;
	if (uFogShow > 0)
	{
		float fogDepth = distance(pos, camPos);

		fog = clamp(1.0 - (uFogDistance - fogDepth) / uFogSize, 0.0, 1.0);
		fog *= clamp(1.0 - (pos.z - uFogHeight) / uFogSize, 0.0, 1.0);
	}
	else
		fog = 0.0;

	return fog;
}

#pragma shady: macro_end
#endregion