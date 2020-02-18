struct FSInput
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct FSOutput
{
	float4 Color0 : SV_Target0;
	float4 Color1 : SV_Target1;
};

Texture2D uShadowExpT : register(t1);
SamplerState uShadowExp : register(s1);

Texture2D uShadowDecT : register(t2);
SamplerState uShadowDec : register(s2);

float2 packShadow(float f)
{
	return float2(floor(f / 255.0) / 255.0, frac(f / 255.0));
}

float unpackShadow(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

FSOutput main(FSInput IN) : SV_TARGET
{
	FSOutput OUT;
	
	float3 shadowExp = uShadowExpT.Sample(uShadowExp, IN.TexCoord).rgb;
	float3 shadowDec = uShadowDecT.Sample(uShadowDec, IN.TexCoord).rgb;
	
	//float3 shadow = uShadowT.Sample(uShadow, IN.TexCoord).rgb;
	float3 shadow = gm_BaseTextureObject.Sample(gm_BaseTexture, IN.TexCoord).rgb;
	
	// Red
	float2 channel = float2(0.0, 0.0);
	channel = packShadow(unpackShadow(shadowExp.r, shadowDec.r) + shadow.r * 255.0);
	
	OUT.Color0.r = channel.x;
	OUT.Color1.r = channel.y;
	
	// Green
	channel = packShadow(unpackShadow(shadowExp.g, shadowDec.g) + shadow.g * 255.0);
	
	OUT.Color0.g = channel.x;
	OUT.Color1.g = channel.y;
	
	// Blue
	channel = packShadow(unpackShadow(shadowExp.b, shadowDec.b) + shadow.b * 255.0);
	
	OUT.Color0.b = channel.x;
	OUT.Color1.b = channel.y;
	
	OUT.Color0.a = 1.0;
	OUT.Color1.a = 1.0;
	
	return OUT;
}