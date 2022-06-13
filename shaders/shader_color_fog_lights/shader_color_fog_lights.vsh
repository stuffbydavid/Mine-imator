/// shader_color_fog_lights

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;

uniform vec4 uBlendColor;

uniform int uIsSky;
uniform int uIsGround;

uniform int uLightAmount;
uniform vec3 uSunDirection;
uniform vec4 uLightData[128];
uniform float uBrightness;
uniform float uBlockBrightness;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying float vBrightness;

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;
uniform float uWindDirection;
uniform float uWindDirectionalSpeed;
uniform float uWindDirectionalStrength;

// TAA
uniform mat4 uTAAMatrix;

// GPU Gems 3: Chapter 6
#define PI 3.14159265
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

vec3 getWind()
{
	return vec3(
		sin((uTime + in_Position.x * 10.0 + in_Position.y + in_Position.z) * (uWindSpeed / 5.0)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y * 10.0 + in_Position.z) * (uWindSpeed / 7.5)) * max(in_Wave.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + in_Position.x + in_Position.y + in_Position.z * 10.0) * (uWindSpeed / 10.0)) * max(in_Wave.y * uWindTerrain, uWindEnable) * uWindStrength
	);
}

vec3 getWindAngle(vec3 pos)
{
	vec2 angle = vec2(cos(uWindDirection), sin(uWindDirection));
	float strength = dot(pos.xy/16.0, angle) / dot(angle, angle);
	float diroff = getNoise((((uTime * uWindDirectionalSpeed) - (strength / 3.0) - (pos.z/64.0)) * .075));
	return vec3(angle * diroff, 0.0) * (1.0 - step(max(in_Wave.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

void main()
{
	vNormal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
	
	vPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position + getWind(), 1.0)).xyz;
	vPosition += getWindAngle(in_Position);
	
	vDepth = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0)).z;
	
	if (uIsSky > 0)
	{
		vDiffuse = vec3(-1.0);
		vBrightness = 0.0;
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
		
		vDiffuse = clamp(vDiffuse, vec3(0.0), vec3(1.0));
		vBrightness = (in_Wave.z * uBlockBrightness + uBrightness);
	}
	
	vColor = in_Colour * uBlendColor;
	vTexCoord = in_TextureCoord;
	
	gl_Position = uTAAMatrix * gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
}
