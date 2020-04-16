#ifndef GRP_FORWARDLIGHTING
#define GRP_FORWARDLIGHTING

#include "Grp_Core.hlsl"

#define MAX_DIRECTIONAL_LIGHTS 4
CBUFFER_START(DIRECTIONAL_LIGHT_BUFFER)
float4 _DLightColor[MAX_DIRECTIONAL_LIGHTS];
float4 _DLightDir[MAX_DIRECTIONAL_LIGHTS];
CBUFFER_END

float3 DiffuseLambert(float3 normalDir)
{
    float3 final=float3(0,0,0);
    for(int i=0;i<MAX_DIRECTIONAL_LIGHTS;i++)
    {
	    float3 lightDirection = normalize(_DLightDir[i].xyz);
	    float diffuse = saturate(dot(normalDir,lightDirection));
        final+=diffuse*_DLightColor[i].rgb;
    }
    return final;
}

float3 DiffuseBlinn(float3 normalDir,float3 viewDir,float gloness)
{
    float3 final=float3(0,0,0);
    for(int i=0;i<MAX_DIRECTIONAL_LIGHTS;i++)
    {
	    float3 lightDirection = normalize(_DLightDir[i].xyz);
	    float diffuse = saturate(dot(normalDir,lightDirection));
        final+=diffuse*_DLightColor[i].rgb;
    }
    return final;
}
#endif