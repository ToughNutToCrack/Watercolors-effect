    Shader "TNTC/OutlineSurface" {
            Properties {
                _Color ("Color", Color) = (1,1,1,1)
                _Outline ("Outline Color", Color) = (0,0,0,1)
                _Size ("Outline Thickness", Float) = 0.01

                _MainTex ("Albedo (RGB)", 2D) = "white" {}
                _Secondary ("Secondary map (RGB)", 2D) = "white" {}
                _Normal ("Normal map", 2D) = "bump"{}
                _NormalStr ("Normal Strength", Range(0,5)) = 1
                _Metallic ("Metallic", Range(0,1)) = 0.1
                _Glossiness ("Smoothness", Range(0,1)) = 0.1
                
                [MaterialToggle] _Saturate ("Saturate", Float) = 0
                [MaterialToggle] _InGreyScale ("Want grey scale?", Float) = 0
            }

            SubShader {
                Tags { "RenderType" = "Opaque" }
                LOD 200
  
                Pass {
                    Stencil {
                        Ref 1
                        Comp NotEqual
                    }
           
                    Cull Off
                    ZWrite Off
       
                    CGPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                    #include "UnityCG.cginc"
                    half _Size;
                    fixed4 _Outline;

                    struct v2f {
                        float4 pos : SV_POSITION;
                    };

                    v2f vert (appdata_base v) {
                        v2f o;
                        v.vertex.xyz += v.normal * _Size;
                        o.pos = UnityObjectToClipPos (v.vertex);
                        return o;
                    }

                    half4 frag (v2f i) : SV_Target{
                        return _Outline;
                    }

                    ENDCG
                }
           
                Tags { "RenderType"="Opaque" }
                LOD 200
       
                Stencil {
                    Ref 1
                    Comp always
                    Pass replace
                }
 
                CGPROGRAM
                #pragma surface surf Standard fullforwardshadows
                #pragma target 3.0

                sampler2D _MainTex;
                sampler2D _Secondary;
                sampler2D _Normal;
                half _NormalStr;
                half _Metallic;
                half _Glossiness;
                half _Saturate;
                half _InGreyScale;
                fixed4 _Color;

                struct Input {
                    float2 uv_MainTex;
                    float2 uv_Secondary;
                    float2 uv_Normal;
                };

                void surf (Input IN, inout SurfaceOutputStandard o) {
                    fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                    fixed4 sec = tex2D (_Secondary, IN.uv_Secondary);
                    c *= sec;
                    o.Normal = UnpackScaleNormal (tex2D (_Normal, IN.uv_Normal), _NormalStr);
                    o.Albedo = c.rgb;
                    o.Metallic = _Metallic;
                    o.Smoothness = _Glossiness;
                    o.Alpha = c.a;

                    float4 grayscale = dot(c.rgb, float3(0.3, 0.59, 0.11));

                    if(_Saturate > 0){
                        c = (c * c)/(grayscale);
                        o.Albedo = c.rgb;
                    }

                    if(_InGreyScale > 0){
                        o.Albedo = grayscale.rgb;
                    }
                }
                ENDCG
            }
            FallBack "Diffuse"
        }