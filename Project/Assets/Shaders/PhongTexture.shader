// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CM163/PhongTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 1.0
        _MainTex ("Main Tex", 2D) = "white" {}
        
    }
    SubShader
    {
		// First pass for directional Lights (and texture)
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
                float3 Ka = float3(1, 1, 1);
                float3 globalAmbient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				float3 ambientComponent = float3(0, 0, 0);//Ka * globalAmbient;

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
				
				return finalColor * tex2D(_MainTex, i.uv);
            }
            
            ENDCG
        }
		// Second pass for multiple point lights
		Pass 
		{
			Tags { "LightMode" = "ForwardAdd" } //Important! In Unity, point lights are calculated in the the ForwardAdd pass
			Blend One One //Turn on additive blending if you have more than one point light


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			uniform float4 _LightColor0; //From UnityCG
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct appdata
			{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
			};

			struct v2f
			{
					float4 vertex : SV_POSITION;
					float3 normal : NORMAL;
					float3 vertexInWorldCoords : TEXCOORD1;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
				o.normal = UnityObjectToWorldNormal(v.normal); //Normal 
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				float3 P = i.vertexInWorldCoords.xyz;
				float3 N = normalize(i.normal);
				float3 V = normalize(_WorldSpaceCameraPos - P);
				float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
				float3 H = normalize(L + V);

				float3 Kd = _Color.rgb; //Color of object
				float3 Ka = UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
				float3 Ks = _SpecColor.rgb; //Color of specular highlighting
				float3 Kl = _LightColor0.rgb; //Color of light


				//AMBIENT LIGHT 
				float3 ambient = Ka;


				//DIFFUSE LIGHT
				float diffuseVal = max(dot(N, L), 0);
				float3 diffuse = Kd * Kl * diffuseVal;


				//SPECULAR LIGHT
				float specularVal = pow(max(dot(N,H), 0), _Shininess);

				if (diffuseVal <= 0) {
					specularVal = 0;
				}

				float3 specular = Ks * Kl * specularVal;

				//FINAL COLOR OF FRAGMENT
				return float4(ambient + diffuse + specular, 1.0);

			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
