Shader "Pass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("color",color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderTag"="BBB" }
        LOD 100
        
        Pass
        {
             Tags{ "LightMode" = "GeneralForward" }
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #pragma multi_compile_instancing
            #include "/Includes/Grp_ForwardPass.hlsl" 
            ENDHLSL

            

        }
    }
}
