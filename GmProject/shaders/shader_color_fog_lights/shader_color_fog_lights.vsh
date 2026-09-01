/// shader_color_fog_lights

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform vec4 uBlendColor;

uniform int uIsSky;
uniform int uIsGround;

uniform int uLightAmount; // static
uniform vec3 uSunDirection; // static
uniform vec4 uLightData[128]; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vNormal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
	vCustom = in_Wave;
	
	if (uIsSky > 0)
	{
		vDiffuse = vec3(-1.0);
	}
	else
	{
		vDiffuse = vec3(0.0);
		int lights = (uIsGround > 0 ? 1 : uLightAmount);
		for (int i = 0; i < lights; i++)
		{
			vec4 data1 = uLightData[i * 2];
			vec4 data2 = uLightData[i * 2 + 1];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w, dis, att;
			
			dis = distance(vPosition, lightPosition);
			att = (i > 0) ? max(0.0, 1.0 - dis / lightRange) : 1.0; // Attenuation factor
			
			vec3 toLight = (i > 0) ? normalize(lightPosition - vPosition) : uSunDirection;
			float dif = max(0.0, dot(vNormal, toLight)) * att; // Diffuse factor
			vDiffuse += data2.rgb * dif;
		}
	}
	
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(vPosition);
}
