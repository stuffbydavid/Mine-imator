uniform float2 uTexScale;
uniform float2 uTexScaleNormal;
uniform float2 uTexScaleMaterial;
uniform float4 uBlendColor;
uniform float uBrightness;
uniform int uIsWater;

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
	float Time: TEXCOORD9;
	float WindDirection: TEXCOORD10;
};

struct FSOutput
{
	float4 Color0 : SV_Target0;
	float4 Color1 : SV_Target1;
	float4 Color2 : SV_Target2;
	float4 Color3 : SV_Target3;
};

Texture2D uTextureT : register(t1);
SamplerState uTexture : register(s1);

Texture2D uTextureNormalT : register(t2);
SamplerState uTextureNormal : register(s2);

Texture2D uTextureMaterialT : register(t3);
SamplerState uTextureMaterial : register(s3);

float4 packDepth(float f)
{
	return float4(floor(f * 255.0) / 255.0, frac(f * 255.0), frac(f * 255.0 * 255.0), 1.0);
}

float4 packNormal(float3 n)
{
	return float4((n + float3(1.0, 1.0, 1.0)) * 0.5, 1.0);
}

float2 packFloat2(float f)
{
	return float2(floor(f / 255.0) / 255.0, frac(f / 255.0));
}

float3 getMappedNormal(float3 normal, float3 worldPos, float2 uv, float wind, float time)
{
	// Get edge derivatives
	float3 posDx = ddx(worldPos);
	float3 posDy = ddy(worldPos);
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
	float3x3 TBN = float3x3(T * float3(invmax, invmax, invmax), B * float3(invmax, invmax, invmax), normal);
	
	// Get normal value from normal map
	float2 normtex = fmod(uv * uTexScaleNormal, uTexScaleNormal);
	
	if (uIsWater > 0)
	{
		float2 angle = float2(cos(wind), sin(wind)) * .125 * time;
		normtex = (worldPos.xy + angle) / 128.0;
	}
	
	float3 normalCoord = uTextureNormalT.Sample(uTextureNormal, normtex).rgb * 2.0 - 1.0;
	
	if (uIsWater > 0)
		normalCoord = lerp(normalCoord, float3(0.0, 0.0, 1.0), .9);
	
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
	clip((baseColor.a < .01) ? -1 : 1);
	
	// Depth
	OUT.Color0 = packDepth(IN.Depth);
	
	float3 n = getMappedNormal(normalize(IN.Normal), IN.WorldPosition, IN.TexCoord, IN.WindDirection, IN.Time);
	n = normalize(mul(n, IN.WorldInv));
	n = normalize(mul(IN.WorldViewInv, n));
	n = packNormal(n).xyz;
	//n = normalize(normalize(IN.Normal) + normalize(n * 0.5));//normalize(lerp(n, IN.Normal, .5));
	
	// Normal X
	float2 channel = float2(0.0, 0.0);
	channel = packFloat2(n.r * 255.0 * 255.0);
	OUT.Color1.r = channel.y;
	OUT.Color2.r = channel.x;
	
	// Normal Y
	channel = packFloat2(n.g * 255.0 * 255.0);
	OUT.Color1.g = channel.y;
	OUT.Color2.g = channel.x;
	
	// Normal Z
	channel = packFloat2(n.b * 255.0 * 255.0);
	OUT.Color1.b = channel.y;
	OUT.Color2.b = channel.x;
	
	OUT.Color1.a = 1.0;
	OUT.Color2.a = 1.0;
	
	// Brightness
	float2 texMat = fmod(IN.TexCoord * uTexScaleMaterial, uTexScaleMaterial);
	float matColor = uTextureMaterialT.Sample(uTextureMaterial, tex).b;
	
	float br = max(0.0, uBlendColor.a * (uBrightness + IN.Custom.z)) * matColor;
	OUT.Color3 = float4(br, br, br, 1.0);
	
	return OUT;
}