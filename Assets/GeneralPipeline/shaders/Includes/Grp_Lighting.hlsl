#ifndef GRP_LIGHTING
#define RP_LIGHTING

#include "Grp_Core.hlsl"

#define MAX_DIRECTIONAL_LIGHTS 4
float4 _DLightColor[MAX_DIRECTIONAL_LIGHTS];
// CBUFFER_END



float3 DiffuseLightLambert(float3 worldNormal)
{
    float3 final=float3(0,0,0);
    for(int i=0;i<MAX_DIRECTIONAL_LIGHTS;i++)
    {
	    // float3 lightDirection = normalize(_GLightPos[i].xyz);
	    // float diffuse = saturate(dot(worldNormal,lightDirection));
        final+=_DLightColor[i].rgb;
    }
    return final;
}
#endif