uniform float2 uTexScale;
uniform float2 uMaterialTexScale;
uniform float2 uNormalTexScale;
uniform float4 uBlendColor;
uniform float uBrightness;
uniform int uSSAOEnable;

struct FSInput
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
	float Depth : DEPTH;
	float3 Normal : NORMAL;
	float3 Custom : TEXCOORD1;
	float3 WorldPosition : TEXCOORD2;
	float3x3 WorldInv : TEXCOORD3;
	float3x3 WorldViewInv : TEXCOORD6;
};

struct FSOutput
{
	float4 Color0 : SV_Target0;
	float4 Color1 : SV_Target1;
	float4 Color2 : SV_Target2;
};

Texture2D uTextureT : register(t1);
SamplerState uTexture : register(s1);

Texture2D uMaterialTextureT : register(t2);
SamplerState uMaterialTexture : register(s2);

Texture2D uNormalTextureT : register(t3);
SamplerState uNormalTexture : register(s3);

float4 packDepth(float f)
{
	 return float4(floor(f * 255.0) / 255.0, frac(f * 255.0), frac(f * 255.0 * 255.0), 1.0);
}

float4 packNormal(float3 n)
{
	return float4((n + float3(1.0, 1.0, 1.0)) * 0.5, 1.0);
}

float3 getMappedNormal(float3 normal, float3 pos, float2 uv)
{
	// Get edge derivatives
	float3 posDx = ddx(pos);
	float3 posDy = ddy(pos);
	float2 texDx = ddx(uv);
	float2 texDy = ddy(uv);
	
	// Calculate tangent/bitangent
	float3 posPx = cross(normal, posDx);
	float3 posPy = cross(posDy, normal);
	float3 T = posPy * texDx.x + posPx * texDy.x;
	float3 B = posPy * texDx.y + posPx * texDy.y;
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	float3x3 TBN = float3x3(T * invmax, B * invmax, normal);
	
	// Get normal value from normal map
	float2 normtex = fmod(uv * uNormalTexScale, uNormalTexScale);
	float3 normalCoord = uNormalTextureT.Sample(uNormalTexture, normtex).rgb * 2.0 - 1.0;
	
	if (normalCoord.z <= 0.0)
		return normal;
	
	return normalize(mul(normalCoord, TBN));
}

FSOutput main(FSInput IN) : SV_TARGET
{
	FSOutput OUT;
	
	// Alpha test
	float2 tex = fmod(IN.TexCoord * uTexScale, uTexScale);
	float4 baseColor = uTextureT.Sample(uTexture, tex);
	clip((baseColor.a < 1.0) ? -1 : 1);
	
	// Depth
	OUT.Color0 = packDepth(IN.Depth);
	
	// Normal
	float3 N = getMappedNormal(normalize(IN.Normal), IN.WorldPosition, IN.TexCoord);
	N = normalize(mul(N, IN.WorldInv));
	N = normalize(mul(IN.WorldViewInv, N));
	OUT.Color1 = packNormal(normalize(N));
	
	// Brightness of SSAO
	float br;
	if (uSSAOEnable > 0)
	{
		float2 matTex = fmod(IN.TexCoord * uMaterialTexScale, uMaterialTexScale);
		float4 mat = uMaterialTextureT.Sample(uMaterialTexture, matTex);
		
		br = max(0.0, uBlendColor.a - ((uBrightness + IN.Custom.z) * mat.b));
	}
	else
		br = 0.0;
	
	OUT.Color2 = float4(br, br, br, 1.0);
	
	return OUT;
}