Shader "Unlit/SH_DVDLogo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Float) = 0.2
        _LogoSize ("Logo Size", Range(0.1, 1.0)) = 0.2
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _LogoSize;
            float4 _BackgroundColor;

            // Calculate the logo position with bouncing effect
            float2 calculateLogoPosition(float time)
            {
                float2 velocity = float2(0.3, 0.4) * _Speed;
                float2 pos = time * velocity;
                
                // Define the maximum position before bouncing
                float2 maxPos = 1.0 - _LogoSize;
                
                // Calculate the position with wrapping
                pos = fmod(pos, maxPos * 2.0);
                
                // Create the bouncing effect
                pos.x = pos.x > maxPos ? 2.0 * maxPos - pos.x : pos.x;
                pos.y = pos.y > maxPos ? 2.0 * maxPos - pos.y : pos.y;
                
                return pos;
            }

            // Change color on each bounce
            float3 getLogoColor(float time)
            {
                float2 velocity = float2(0.3, 0.4) * _Speed;
                float2 maxPos = 1.0 - _LogoSize;
                
                // Count the number of bounces
                float2 bounceCount = floor(time * velocity / maxPos);
                float totalBounces = bounceCount.x + bounceCount.y;
                
                float hue = frac(totalBounces * 0.1618); // Change hue based on bounces
                
                // Convert hue to RGB
                float3 col;
                float h = hue * 6.0;
                float x = 1.0 - abs(fmod(h, 2.0) - 1.0);
                
                if (h < 1.0) col = float3(1, x, 0);
                else if (h < 2.0) col = float3(x, 1, 0);
                else if (h < 3.0) col = float3(0, 1, x);
                else if (h < 4.0) col = float3(0, x, 1);
                else if (h < 5.0) col = float3(x, 0, 1);
                else col = float3(1, 0, x);
                
                return col;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 logoPos = calculateLogoPosition(_Time.y);
                
                // Calculate UV coordinates relative to logo position
                float2 logoUV = (i.uv - logoPos) / _LogoSize;
                
                // If we are inside the logo area
                if (logoUV.x >= 0.0 && logoUV.x <= 1.0 && 
                    logoUV.y >= 0.0 && logoUV.y <= 1.0)
                {
                    // Sample logo texture
                    fixed4 texColor = tex2D(_MainTex, logoUV);
                    
                    // Apply tint color based on bounces
                    float3 tintColor = getLogoColor(_Time.y);
                    fixed4 col = fixed4(texColor.rgb * tintColor, texColor.a);
                    
                    // If logo texture has transparency, blend with background
                    col.rgb = lerp(_BackgroundColor.rgb, col.rgb, texColor.a);
                    
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }
                else
                {
                    // Backgfround
                    fixed4 col = _BackgroundColor;
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }
            }
            ENDCG
        }
    }
}