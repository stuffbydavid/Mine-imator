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