uniform float2 uTexScale;
uniform float4 uBlendColor;
uniform float uSSS;
uniform float3 uSSSRadius;
uniform float4 uSSSColor;
uniform float uBlockSSS;

struct FSInput
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
	float3 Normal : NORMAL;
	float4 Custom : TEXCOORD1;
};

struct FSOutput
{
	float4 Color0 : SV_Target0;
	float4 Color1 : SV_Target1;
	float4 Color2 : SV_Target2;
};

Texture2D uTextureT : register(t1);
SamplerState uTexture : register(s1);

float3 packSSS(float f)
{
	f = clamp(f / 256.0, 0.0, 1.0);
	return float3(floor(f * 255.0) / 255.0, frac(f * 255.0), frac(f * 255.0 * 255.0));
}

FSOutput main(FSInput IN) : SV_TARGET
{
	FSOutput OUT;
	
	// Alpha test
	float2 tex = fmod(IN.TexCoord * uTexScale, uTexScale);
	float4 baseColor = uTextureT.Sample(uTexture, tex);
	clip((baseColor.a < 1.0) ? -1 : 1);
	
	// Subsurface depth
	OUT.Color0 = float4(packSSS(max(IN.Custom.w * uBlockSSS, uSSS)), 1.0);
	
	// Channel radius
	OUT.Color1 = float4(uSSSRadius, 1.0);
	
	// Subsurface color
	OUT.Color2 = uSSSColor;
	
	return OUT;
}