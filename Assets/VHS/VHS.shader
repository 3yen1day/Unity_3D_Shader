Shader "Unlit/VHS"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BleedTaps("BleedTaps", Int) = 4
		_BleedDelta("BleedDelta", Float) = 2.0
		_FringeDelta("FringeDelta", Float) = 0
		_Scanline("Scanline", Float) = 0
		_src("src", Float) = 0
		_SamplingDistance("Sampling Distance", float) = 1.0
		_NoiseY("NoiseY", float) = 0.0
	}

		SubShader
		{
			Cull Off ZWrite Off ZTest Always

			Pass
			{
				 Tags
			{
				"RenderType" = "Opaque"
				"Queue" = "Geometry"
			}

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


				sampler2D _MainTex;
				float4 _MainTex_ST;
				int _BleedTaps;
				float _BleedDelta;
				float _FringeDelta;
				float _Scanline;
				float _NoiseY;


				static const int samplingCount = 10;
				half _Weights[samplingCount];



				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}


				float rand(float2 co) {
					return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
				}

				float2 mod(float2 a, float2 b)
				{
					return a - floor(a / b) * b;
				}

				//RGBからYYIQへの変換
				half3 RGB2YIQ(fixed3 rgb)
				{
					rgb = saturate(rgb);
					#ifndef UNITY_COLORSPACE_GAMMA //←が定義されていなければ
					rgb = LinearToGammaSpace(rgb); //これを実行する
					#endif //#ifndefの終端を示す（デフォで1行）
					return mul(half3x3(0.299, 0.587, 0.114,
						0.596, -0.274, -0.322,
						0.211, -0.523, 0.313), rgb);
				}

				//YIQからRGBの変換
				fixed3 YIQ2RGB(half3 yiq)
				{
					half3 rgb = mul(half3x3(1, 0.956, 0.621,
						1, -0.272, -0.647,
						1, -1.106, 1.703), yiq);
					rgb = saturate(rgb);
					#ifndef UNITY_COLORSPACE_GAMMA
					rgb = GammaToLinearSpace(rgb);
					#endif
					return rgb;
				}

				half3 SampleYIQ(float2 uv, float du)
				{
					uv.x += du;
					return RGB2YIQ(tex2D(_MainTex, uv).rgb);
				}

				float4 hash42(float2 p) {
					float4 p4 = frac(float4(p.xyxy) * float4(443.8975, 397.2973, 491.1871, 470.7827));
					p4 += dot(p4.wzxy, p4 + 19.19);
					return frac(float4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
				}

				float hash(float n) {
					return frac(sin(n)*43758.5453123);
				}

				float n(in float3 x) {
					float3 p = floor(x);
					float3 f = frac(x);
					f = f * f*(3.0 - 2.0*f);
					float n = p.x + p.y*57.0 + 113.0*p.z;
					float res = lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
						lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
						lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
							lerp(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
					return res;
				}

				float nn(float2 p, float t) {

					float y = p.y;
					float s = t * 2.;

					float v = (n(float3(y*0.01 + s, 1.0, 1.0)) + 0.0)
						*(n(float3(y*0.011 + 1000.0 + s, 1.0, 1.0)) + 0.0)
						*(n(float3(y*0.51 + 421.0 + s, 1.0, 1.0)) + 0.0)
						;
					//v*= n( vec3( (fragCoord.xy + vec2(s,0.))*100.,1.0) );
					v *= hash42(float2(p.x + t * 0.01, p.y)).x + .3;


					v = pow(v + .3, 1.);
					if (v < .7) v = 0.;  //threshold
					return v;
				}



				fixed4 frag(v2f i) : SV_Target
				{

				float2 uv = i.uv;


				//ブロックノイズ
				if (uv.y == _NoiseY) _NoiseY = 0.5;

				if (uv.y > _NoiseY && uv.y < _NoiseY + 0.05) {
					uv.y = _NoiseY + 0.05;
				}

				half3 yiq = SampleYIQ(uv, 0);


				// Bleeding
				for (uint i = 0; i < _BleedTaps; i++)
				{
					yiq.y += SampleYIQ(uv, -_BleedDelta * i).y;
					yiq.z += SampleYIQ(uv, +_BleedDelta * i).z;
				}
				yiq.yz /= _BleedTaps + 1;

				// Fringing
				half y1 = SampleYIQ(uv, -_FringeDelta).x;
				half y2 = SampleYIQ(uv, +_FringeDelta).x;
				yiq.yz += y2 - y1;


				// Scanline
				half scan = sin(uv.y * 500 * UNITY_PI + _Time.y * 3);
				scan = lerp(1, (scan + 1) / 2, _Scanline);

				float3 col = YIQ2RGB(yiq*scan);


				//テープノイズ
				float2 hw = _ScreenParams.xy;
				float linesN = 500;
				float one_y = hw.y / linesN;
				uv = floor(((uv + 0.5)*0.9)*hw.xy / one_y)*one_y;


				float col2 = nn(((uv + 0.5)*0.9), _Time * 10);
				if (col2 > 0.5) {
					col = float3(col2, col2, col2);
				}

				return fixed4(col,1);
				}
				ENDCG
			}
		}
}