uniform sampler2D uTexture;
uniform vec3 uCameraPosition;
uniform int uColorsExt;
uniform int uGlowPass;
uniform int uGlowTexture;
uniform vec4 uGlowColor;
uniform int uOnlyRenderGlow;
uniform float uGamma;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

void main()
{
	vec4 baseColor = vColor * texture2D(uTexture, vTexCoord);
	handleAlphaDiscard(vPosition, baseColor);
	
	float fog = getFog(vPosition, uCameraPosition);
	
	gl_FragData[1] = vec4(0.0);
	
	if (uGlowPass > 0)
	{
		vec4 glowColor = baseColor;
		if (uGlowTexture == 1)
		{
			if (uColorsExt == 1)
				applyColorTransform(glowColor, true);
			
			glowColor.rgb *= uGlowColor.rgb;
		}
		else
			glowColor.rgb = uGlowColor.rgb;
		
		glowColor.rgb = pow(max(glowColor.rgb, vec3(0.0)), vec3(uGamma));
		glowColor.rgb *= vec3(1.0 - fog);
		
		gl_FragData[1] = glowColor;
	}
	
	gl_FragData[0] = uOnlyRenderGlow == 1 ? vec4(0.0) : vec4(vec3(fog), 1.0);
}
