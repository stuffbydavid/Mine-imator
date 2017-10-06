uniform float uAlpha;
uniform float uBrightness;

struct FSInput
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
	float Depth : DEPTH;
	float3 Normal : NORMAL;
	float3 Custom : TEXCOORD1;
};

struct FSOutput
{
	float4 Color0 : SV_Target0;
	float4 Color1 : SV_Target1;
	float4 Color2 : SV_Target2;
};

Texture2D uTextureT : register(t1);
SamplerState uTexture : register(s1);

float4 packDepth(float f)
{
	return float4(floor(f * 255.0) / 255.0, frac(f * 255.0), frac(f * 255.0 * 255.0), 1.0);
}

float4 packNormal(float3 n)
{
	return float4((n + float3(1.0, 1.0, 1.0)) / 2.0, 1.0);
}

FSOutput main(FSInput IN) : SV_TARGET
{
	FSOutput OUT;
	
	// Alpha test
	float4 baseColor = uTextureT.Sample(uTexture, IN.TexCoord);
	clip((baseColor.a < 1.0) ? -1 : 1);
	
	// Depth
	OUT.Color0 = packDepth(IN.Depth);
	
	// Normal
	OUT.Color1 = packNormal(IN.Normal);
	
	// Brightness
	float br = max(0.0, uAlpha - uBrightness - IN.Custom.z);
	OUT.Color2 = float4(br, br, br, 1.0);
	
	return OUT;
}