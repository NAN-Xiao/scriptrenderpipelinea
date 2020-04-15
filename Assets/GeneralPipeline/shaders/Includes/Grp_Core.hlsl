#ifndef GPR_CORE
#define GPR_CORE
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

CBUFFER_START(UnityPerFrame) 
	float4x4 unity_MatrixVP;
CBUFFER_END
CBUFFER_START(UnityPerDraw) 
	float4x4 unity_ObjectToWorld;
CBUFFER_END
#define UNITY_MATRIX_M unity_ObjectToWorld
#endif