Shader "Unlit/Kairal_Vert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "Black" {}
        _ScanlineTex ("ScanlineTex", 2D) = "Black" {}
        _RimColor ("RimColor", Color) = (0,0,1,1)
        _RimPower ("RimPower", Range(0.1, 10)) = 5.0
        _OverlayColor ("OverlayColor", Color) = (0,0,1,1)
        _NoiseSpeed ("NoiseSpeed", Range(1.0,10.0)) = 6.0
        _NoiseSize ("NoiseSize", Range(0.0,3.0)) = 0.8
        _NoiseRange ("NoiseRange", Range(0.9,1.0)) = 0.998
        //_Smoothness ("Smoothness", Range(0, 1)) = 1
        _Alpha ("Alpha", Range(0.0, 1.0)) = 0.7
        _ObjectSize ("ObjectSize", Range(0.0, 10.0)) = 2.0
        _DissolveSpeed ("DissolveSpeed", Range(0.0, 5.0)) = 3.0
        _T ("T", Float) = 0.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        //先に深度を書き込む
		Pass{
  		  ZWrite ON
  		  ColorMask 0
		}

        //透明
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 
        
        
        //アウトライン
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile  _ Dissolve_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex += float4(v.normal * 0.006f, 0);   
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            float4 _RimColor;
            float _Alpha;
            float _ObjectSize;
            float _DissolveSpeed;
            float _T;
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _RimColor;

                #ifdef Dissolve_ON
                col.a=saturate(saturate(abs(-i.worldPos.y+_ObjectSize)-_T*_DissolveSpeed)*5.0)*_Alpha;
                #else
                col.a = _Alpha;
                #endif                  
                return col;
            }
            ENDCG
        }
        
        //本体
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ Dissolve_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : NORMAL;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ScanlineTex;
            float4 _ScanlineTex_ST;
            float4 _RimColor;
            float4 _OverlayColor;
            float _NoiseSpeed;
            float _NoiseSize;
            float _NoiseRange;
            float _RimPower;
            float _Alpha;
            float _ObjectSize;
            float _DissolveSpeed;
            float _T;

            float rand(float co){
                return frac(sin(dot(co,12.9898)) * 43758.5453);
            }

            float rand2 (fixed2 p) { 
            return frac(sin(dot(p, fixed2(12.9898,78.233))) * 43758.5453);
            }

            float Graph( fixed x){
                return pow(_NoiseSize*abs(sin(10*x)*(-sin(x*2)+1))*0.5,2.0)*_Alpha;
            }

            v2f vert (appdata v)
            {
                v2f o;

                float offset = Graph(v.vertex.y);
                float t = _Time.z*_NoiseSpeed;
                float offsetTF = rand(floor(t)+v.vertex.z);
                if(offsetTF>_NoiseRange) v.vertex.z += offset*(1-frac(t))*_NoiseSize;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //if (col.r>0) discard;

                //スキャンラインA
                //float2 scan = i.worldPos + float2 (0, _Time.x*-2.0);
                //float4 scanLine = tex2D(_ScanlineTex, scan);

                //スキャンラインB
                float scanLine = frac(i.worldPos.y*5.0-_Time.y);

                //ノイズ
                float noise = rand2(i.uv+floor(_Time.y*10.0));

                //リムライト
                half rim = 1.0-saturate(dot(i.viewDir, i.worldNormal));
				fixed4 rimColor = _RimColor * pow (rim, _RimPower);

                col = col + rimColor;

                //オーバーレイ
                if (col.r < 0.5){
                    col.r = 2.0*col.r*_OverlayColor.r;
                }else{
                    col.r = 1.0 - 2.0 * (1.0 - col.r) * (1.0 - _OverlayColor.r);
                }

                if (col.g < 0.5){
                    col.g = 2.0*col.g*_OverlayColor.g;
                }else{
                    col.g = 1.0 - 2.0 * (1.0 - col.g) * (1.0 - _OverlayColor.g);
                }

                if (col.b < 0.5){
                    col.b = 2.0*col.b*_OverlayColor.b;
                }else{
                    col.b = 1.0 - 2.0 * (1.0 - col.b) * (1.0 - _OverlayColor.b);
                }
                col.rgb-= noise/4.0;
                col += scanLine*0.4;
                col.a = _Alpha;
                #ifdef Dissolve_ON
                col.a=saturate(saturate(abs(-i.worldPos.y+_ObjectSize)-_T*_DissolveSpeed)*5.0)*_Alpha;
                #else
                col.a = _Alpha;
                #endif    
                return col;
            }
            ENDCG
        }
	}

	FallBack "Standard"
    
}
