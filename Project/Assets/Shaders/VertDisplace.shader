// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CM163/PhongVert"
{
    Properties
    {
		_MainTex("Main Tex", 2D) = "white" {}
		_Displacement("Displacement", Float) = 1.0
    }
    SubShader
    {
		// First pass for directional Lights
        pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
			sampler2D _MainTex;
			fixed _Displacement;

            struct vertexShaderInput 
            {
                float4 position: POSITION;
				float2 uv : TEXCOORD0;
            };
            
            struct vertexShaderOutput
            {
                float4 position: SV_POSITION;
				float2 uv : TEXCOORD0;
            };
            
            vertexShaderOutput vert(vertexShaderInput v)
            {
                vertexShaderOutput o;				
				if (tex2Dlod(_MainTex, float4(v.uv.xy, 0, 0)).r > 0.5)
				{
					v.position.y += _Displacement;
					v.position.x += _Displacement;
				}	
				else
				{
					v.position.y -= _Displacement;
				}
				o.position = UnityObjectToClipPos(v.position);
				o.uv = v.uv;
                return o;
            }
            
            float4 frag(vertexShaderOutput i):SV_Target
            {
				return float4(tex2D(_MainTex, i.uv).r,tex2D(_MainTex, i.uv).r,tex2D(_MainTex, i.uv).r,1);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
