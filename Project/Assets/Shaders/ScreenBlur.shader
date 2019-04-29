Shader "cm 163/ScreenBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Steps("Steps", Float) = 10
		_Intensity("Intensity", Float) = 0.5
        
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            uniform float4 _MainTex_TexelSize; //special value
            uniform float _Steps;
			uniform float _Intensity;
			uniform float3x3 kernel = float3x3(0, -1, 0, -1, 5, -1, 0, -1, 0);
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            fixed4 frag (v2f_img i) : COLOR
            {
                float2 texel = float2(
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
        
        
                float3 avg = 0.0;
        
                int steps = ((int)_Steps) * 2 + 1;
                if (steps < 0) {
                    avg = tex2D( _MainTex, i.uv).rgb;
                } 
				else 
				{
        
					int x, y;
        
					for ( x = -steps/2; x <=steps/2 ; x++) 
					{
						for (int y = -steps/2; y <= steps/2; y++) 
						{
							avg += tex2D( _MainTex, i.uv + texel * float2( x, y ) ).rgb;
						}
					}
        
					avg /= steps * steps;
				}             
        
				return float4(lerp(tex2D(_MainTex, i.uv), avg, _Intensity), 1.0);
            }
            ENDCG
        }
    }
}
