// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CM163/PhongBlendTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 1.0
        _MainTex ("Main Tex", 2D) = "white" {}
		_Tex2("Tex2", 2D) = "white" {}
        
    }
    SubShader
    {
		pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _LightColor0;
			float4 _Color;
			float4 _SpecularColor;
			float _Shininess;
			sampler2D _MainTex;
			sampler2D _Tex2;

			struct vertexShaderInput
			{
				float4 position: POSITION;
				float2 uv: TEXCOORD0;
			};

			struct vertexShaderOutput
			{
				float4 position: SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			vertexShaderOutput vert(vertexShaderInput v)
			{
				vertexShaderOutput o;
				o.position = UnityObjectToClipPos(v.position);
				o.uv = v.uv;
				return o;
			}

			float4 frag(vertexShaderOutput i) :SV_Target
			{
				return lerp(tex2D(_MainTex, i.uv), tex2D(_Tex2, i.uv), 0.5);
			}
			ENDCG
		}
        pass 
        {
			Tags 
			{ 
				"LightMode" = "ForwardAdd" //Important! In Unity, point lights are calculated in the the ForwardAdd pass
				"Rendermode" = "Opaque"
			} 
			Blend SrcColor One //Turn on additive blending if you have more than one point light
			Lighting On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            float4 _LightColor0;
            float4 _Color;
            float4 _SpecularColor;
            float _Shininess;
            sampler2D _MainTex;
			sampler2D _Tex2;
            
            struct vertexShaderInput 
            {
                float4 position: POSITION;
                float3 normal: NORMAL; 
                float2 uv: TEXCOORD0;
            };
            
            struct vertexShaderOutput
            {
                float4 position: SV_POSITION;
                float3 normal: NORMAL;
                float3 vertInWorldCoords: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };
            
            vertexShaderOutput vert(vertexShaderInput v)
            {
                vertexShaderOutput o;
                o.vertInWorldCoords = mul(unity_ObjectToWorld, v.position);
                o.position = UnityObjectToClipPos(v.position);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag(vertexShaderOutput i):SV_Target
            {
                float3 Ka = float3(0.1, 0.1, 0.1);
                float3 globalAmbient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				float3 ambientComponent = Ka *globalAmbient;

                float3 P = i.vertInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 Kd = _Color.rgb;
                float3 lightColor = _LightColor0.rgb;
                float3 diffuseComponent = Kd * lightColor * max(dot(N, L), 0);
                
                float3 Ks = _SpecularColor.rgb;
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 H = normalize(L + V);
                float3 specularComponent = Ks * lightColor * pow(max(dot(N, H), 0), _Shininess);
                
                
                float4 finalColor = float4(ambientComponent + diffuseComponent + specularComponent, 1);
				
				return float4((finalColor * lerp(tex2D(_MainTex, i.uv), tex2D(_Tex2, i.uv), 0.5)).xyz, 1);
            }          
            ENDCG
        }
    }
    FallBack "Diffuse"
}
