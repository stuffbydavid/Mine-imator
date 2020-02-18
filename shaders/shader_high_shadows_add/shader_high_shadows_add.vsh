struct VSInput
{
    float3 Position : POSITION;
    float2 TexCoord : TEXCOORD0;
};


struct VSOutput
{
    float4 Position : SV_POSITION;
    float2 TexCoord : TEXCOORD0;
};


VSOutput main(VSInput IN)
{
	VSOutput OUT;

	OUT.TexCoord = IN.TexCoord; 
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(IN.Position, 1.0));

	return OUT;
}