cbuffer PointBuffer : register(b0)
{
	float4 _pointEye; // Light position and vertical forward Z
	float4 _pointProjection; // X/Y scale and Z scale/offset
	float4 _pointVertical; // Side X, up Y/Z and forward Y
};

float4 projectPointFace(float3 pos, uint face)
{
	float3 view;
	switch (face)
	{
		case 0: view = float3(pos.y, pos.z, pos.x); break;
		case 1: view = float3(-pos.y, pos.z, -pos.x); break;
		case 2: view = float3(-pos.x, pos.z, pos.y); break;
		case 3: view = float3(pos.x, pos.z, -pos.y); break;
		case 4: view = float3(pos.x * _pointVertical.x, pos.y * _pointVertical.y + pos.z * _pointVertical.z, pos.y * _pointVertical.w + pos.z * _pointEye.w); break;
		default: view = float3(pos.x * _pointVertical.x, -pos.y * _pointVertical.y + pos.z * _pointVertical.z, pos.y * _pointVertical.w - pos.z * _pointEye.w); break;
	}
	
	return float4(view.xy * _pointProjection.xy, view.z * _pointProjection.z + _pointProjection.w, view.z);
}

[maxvertexcount(18)]
void main(triangle Vars input[3], inout TriangleStream<PointVars> stream)
{
	float3 relative[3];
	[unroll] for (uint v = 0; v < 3; v++)
		relative[v] = input[v].vPosition - _pointEye.xyz;
	
	[unroll] for (uint face = 0; face < 6; face++)
	{
		float4 p[3];
		[unroll] for (uint v = 0; v < 3; v++)
			p[v] = projectPointFace(relative[v], face);
		
		// Reject triangles outside this face before emitting geometry
		if (all(float3(p[0].x, p[1].x, p[2].x) < -float3(p[0].w, p[1].w, p[2].w)) ||
			all(float3(p[0].x, p[1].x, p[2].x) > float3(p[0].w, p[1].w, p[2].w)) ||
			all(float3(p[0].y, p[1].y, p[2].y) < -float3(p[0].w, p[1].w, p[2].w)) ||
			all(float3(p[0].y, p[1].y, p[2].y) > float3(p[0].w, p[1].w, p[2].w)) ||
			all(float3(p[0].z, p[1].z, p[2].z) < 0.0) ||
			all(float3(p[0].z, p[1].z, p[2].z) > float3(p[0].w, p[1].w, p[2].w)))
        {
            continue;
        }
		
		[unroll] for (uint v = 0; v < 3; v++)
		{
			PointVars output;
			output.gl_Position = p[v];
			output.vPosition = input[v].vPosition;
			output.vTexCoord = input[v].vTexCoord;
			output.vColor = input[v].vColor;
			output._vObjIndex = input[v]._vObjIndex;
			output._viewport = face;
			
			stream.Append(output);
		}
		
		stream.RestartStrip();
	}
}
