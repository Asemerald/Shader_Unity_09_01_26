Shader "Custom/ProceduralShapes"
{
    Properties
    {
        _TimeSpeed("Animation Speed", Float) = 1.0
        _Color1("Primary Color", Color) = (1,0,0,1)
        _Color2("Secondary Color", Color) = (0,0,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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

            float _TimeSpeed;
            float4 _Color1;
            float4 _Color2;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.0 - 1.0; // On centre les UV de -1 à 1
                return o;
            }

            // --------- Fonctions de formes ---------
            float Circle(float2 uv, float2 center, float radius)
            {
                return smoothstep(radius, radius - 0.01, length(uv - center));
            }

            float Square(float2 uv, float2 center, float size)
            {
                float2 d = abs(uv - center);
                float inside = step(d.x, size) * step(d.y, size);
                return inside;
            }

            float Triangle(float2 uv, float2 center, float size)
            {
                float2 p = uv - center;
                p.x = abs(p.x);
                return step(p.y, -p.x + size) * step(p.y, 0);
            }

            float Star(float2 uv, float2 center, float radius, int points)
            {
                float2 dir = uv - center;
                float angle = atan2(dir.y, dir.x);
                float len = length(dir);
                float m = cos(angle * points * 0.5) * radius;
                return smoothstep(m, m - 0.01, len);
            }

            float Line(float2 uv, float2 start, float2 end, float width)
            {
                float2 dir = end - start;
                float2 perp = float2(-dir.y, dir.x);
                float len = length(dir);
                float d = abs(dot(uv - start, normalize(perp)));
                float t = dot(uv - start, dir) / (len*len);
                return step(0, t) * step(t, 1) * smoothstep(width, 0.0, d);
            }

            

            // 
            float pattern(float2 uv, float t)
            {
                // Cercle animé
                float c = Circle(uv, float2(sin(t), cos(t)) * 0.5, 0.2);

                // Carré en rotation
                float2 sqPos = float2(cos(t*0.5), sin(t*0.5)) * 0.5;
                float s = Square(uv, sqPos, 0.15);

                // Combinaison simple
                float combined = max(c, s);
                return combined;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float t = _Time.y * _TimeSpeed;

                float value = pattern(i.uv, t);
                fixed4 col = lerp(_Color1, _Color2, value);
                return col;
            }
            ENDCG
        }
    }
}
