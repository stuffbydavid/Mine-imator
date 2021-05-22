struct VSInput
{
	float4 Position : POSITION;
	float3 Normal : NORMAL;
	float2 TexCoord : TEXCOORD0;
	float3 Color : COLOR;
	float4 Custom : TEXCOORD1;
};

struct VSOutput
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
	float3 Normal : NORMAL;
	float4 Custom : TEXCOORD1;
};

// Wind
uniform float uTime;
uniform float uWindEnable;
uniform float uWindTerrain;
uniform float uWindSpeed;
uniform float uWindStrength;
uniform float uWindDirection;
uniform float uWindDirectionalSpeed;
uniform float uWindDirectionalStrength;

// GPU Gems 3: Chapter 6
#define PI 3.14159265
float getNoise(float v)
{
	return cos(v * PI) * cos(v * 3.0 * PI) * cos(v * 5.0 * PI) * cos(v * 7.0 * PI) + sin(v * 5.0 * PI) * 0.1;
}

float4 getWind(float4 pos, float4 custom)
{
	return float4(
		sin((uTime + pos.x * 10.0 + pos.y + pos.z) * (uWindSpeed / 5.0)) * max(custom.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + pos.x + pos.y * 10.0 + pos.z) * (uWindSpeed / 7.5)) * max(custom.x * uWindTerrain, uWindEnable) * uWindStrength,
		sin((uTime + pos.x + pos.y + pos.z * 10.0) * (uWindSpeed / 10.0)) * max(custom.y * uWindTerrain, uWindEnable) * uWindStrength,
		0
	);
}

float3 getWindAngle(float3 pos, float4 custom)
{
	float2 angle = float2(cos(uWindDirection), sin(uWindDirection));
	float strength = dot(pos.xy/16.0, angle) / dot(angle, angle);
	float diroff = getNoise((((uTime * uWindDirectionalSpeed) - (strength / 3.0) - (pos.z/64.0)) * .075));
	return float3(angle * diroff, 0.0) * (1.0 - step(max(custom.x * uWindTerrain, uWindEnable), 0.0)) * uWindDirectionalStrength;
}

VSOutput main(VSInput IN)
{
	VSOutput OUT;
	
	// Diffuse
	float3 pos = mul(gm_Matrices[MATRIX_WORLD], float4(IN.Position + getWind(IN.Position, IN.Custom))).xyz;
	pos += getWindAngle(IN.Position, IN.Custom);
	
	OUT.Position = mul(gm_Matrices[MATRIX_PROJECTION], mul(gm_Matrices[MATRIX_VIEW], float4(pos, 1.0)));
	OUT.TexCoord = IN.TexCoord;
	
	// Custom
	OUT.Custom = IN.Custom;
	
	return OUT;
}

