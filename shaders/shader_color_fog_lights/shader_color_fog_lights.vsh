/// shader_color_fog_lights

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec3 in_Wave;

uniform vec4 uBlendColor;
uniform int uIsGround;
uniform int uIsSky;

uniform int uLightAmount;
uniform vec4 uLightData[128];
uniform vec4 uAmbientColor;
uniform float uBrightness;
uniform float uBlockBrightness;

varying vec3 vPosition;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Wave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

void main()
{
	vec3 worldNormal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
	vec3 off = getWind();
	
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + off, 1.0)).xyz;
	vDepth = (gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Position + off, 1.0)).z;
	
	if (uIsGround > 0 || uIsSky > 0)
		vDiffuse = vec3(1.0);
	else
	{
		vDiffuse = uAmbientColor.rgb;
		for (int i = 0; i < uLightAmount; i++)
		{
			vec4 data1 = uLightData[i * 2];
			vec4 data2 = uLightData[i * 2 + 1];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w, dis, att;
		
			dis = distance(vPosition, lightPosition);
			att = (i > 0) ? max(0.0, 1.0 - dis / lightRange) : 1.0; // Attenuation factor
		
			vec3 toLight = normalize(lightPosition - vPosition);
			float dif = max(0.0, dot(worldNormal, toLight)) * att; // Diffuse factor
			vDiffuse += data2.rgb * dif;
		}
	
		vDiffuse = clamp(vDiffuse, 0.0, 1.0);
		vDiffuse = mix(vDiffuse, vec3(1.0), in_Wave.z * uBlockBrightness + uBrightness);
	}
	
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position + off, 1.0);
}
