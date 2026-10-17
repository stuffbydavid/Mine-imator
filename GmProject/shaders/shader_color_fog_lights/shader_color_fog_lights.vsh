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
uniform vec3 uLightAreaDirections[64]; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;
varying vec3 vPlaceNormal;
varying float vPlaceDistance;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)
#pragma shady: inline(common_util.MATRIX_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vec3 modelNormal = getModelNormal(in_Normal, in_Position);
	vNormal = normalize(inverse2(gm_Matrices[MATRIX_WORLD]) * modelNormal);
	vCustom = in_Wave;
	
	if (uIsSky > 0)
	{
		vDiffuse = vec3(-1.0);
	}
	else
	{
		vDiffuse = vec3(0.0);
		int lights = (uIsGround > 0 ? 1 : uLightAmount);
		if (lights > 64)
			lights = 64;
		for (int i = 0; i < lights; i++)
		{
			vec4 data1 = uLightData[i * 2];
			vec4 data2 = uLightData[i * 2 + 1];
			if (dot(uLightAreaDirections[i], uLightAreaDirections[i]) > 0.0)
				continue;
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
	
	vPlaceNormal = modelNormal;
	vPlaceDistance = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0)).z;
	
	gl_Position = getClipPosition(vPosition);
}
