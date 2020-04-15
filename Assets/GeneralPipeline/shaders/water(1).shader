Shader "water"
{
    Properties
    {
        _Color("color",color)=(1,1,1,1)
        _Main("main",2d)= "white" {}
        _NormalMap ("Normal", 2D) = "white" {}
        _scale("BumpScale",range(0,1))=1
        _speedX("speedx",float)=1
        _speedY("speedy",float)=1

    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" }
        LOD 100
        Pass
        {
            blend srcalpha oneminussrcalpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityImageBasedLighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 normal:NORMAL;
                float4 tan:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 wdnormal:TEXCOORD3;
                float4 wdtangent:TEXCOORD4;
                float3 wdbtangent:TEXCOORD5;
                float3 worldPos:TEXCOORD6;
            };

            sampler2D _NormalMap,_Main;
            float4 _NormalMap_ST,_Main_ST;
            float4 _Color;
            float _scale,_speedx,_speedy;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=v.uv*_NormalMap_ST.xy+_NormalMap_ST.zw;
                o.uv2=v.uv*_Main_ST.xy+_Main_ST.zw;
                o.wdnormal=mul(unity_ObjectToWorld,v.normal);
                o.wdtangent=mul(unity_ObjectToWorld,v.tan);
                o.wdbtangent=cross(o.wdnormal,o.wdtangent.xyz)*o.wdtangent.w;
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 speed=float2(_speedx,_speedy)+_Time.x;
                float4 color=tex2D(_Main,i.uv2);

                float3 bum1=UnpackNormal(tex2D(_NormalMap,i.uv+speed));
                float3 bum2=UnpackNormal(tex2D(_NormalMap,i.uv-speed));
                bum1*=bum2;
                float3 wn=normalize(i.wdnormal);
                float3 wt=normalize(i.wdtangent);
                float3 wb=normalize(i.wdbtangent);
                float3x3 tangentTransform = float3x3(wt, wb, wn);
                float3 worldN=mul(bum1,tangentTransform);
                worldN.xy*=_scale;
                fixed3 view = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 refdir=reflect(-view, worldN);
                half4 hdr=UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refdir);
                _Color.rgb+=hdr;
                _Color.a*=color.a;
                return _Color;
            }
            ENDCG
        }
    }
}
