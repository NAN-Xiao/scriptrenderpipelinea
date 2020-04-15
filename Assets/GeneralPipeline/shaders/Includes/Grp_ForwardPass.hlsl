#ifndef GRP_FORWAEDPASS
#define GRP_FORWAEDPASS

#include "Grp_Lighting.hlsl"
// #include "Grp_Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
UNITY_INSTANCING_BUFFER_START(PerInstance)
	UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_INSTANCING_BUFFER_END(PerInstance)

struct VertexInput {
	float4 pos : POSITION;
	float3 normal:NORMAL;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput {
	float4 clipPos : SV_POSITION;
	float3 normal:NORMAL;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};


VertexOutput LitPassVertex(VertexInput input) {
	VertexOutput output;
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	float4 worldPos = mul(UNITY_MATRIX_M, float4(input.pos.xyz, 1));
	output.clipPos = mul(unity_MatrixVP, worldPos);
	output.normal = mul((float3x3)UNITY_MATRIX_M, input.normal);
	return output;
}

float4 LitPassFragment(VertexOutput input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);
	input.normal = normalize(input.normal);
	float4 color = UNITY_ACCESS_INSTANCED_PROP(PerInstance, _Color);
	float3 _light=float3(0,0,0);
	for(int i=0;i<MAX_DIRECTIONAL_LIGHTS;i++)
	{
		_light+=_DLightColor[i].rgb;
	}
	color.rgb*=DiffuseLightLambert(input.normal);
	return color;
}
	#endif  //MYRP_UNLIT_INCLUDED