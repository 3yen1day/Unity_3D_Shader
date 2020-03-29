
Shader "Custom/Kougaku2"
{
	Properties
	{
		_Shift("Shift", Range(0.0, 1.0)) = 0
		_Amount("Distort", Float) = 0.0
		_Size("Size", int) = 10
	}

		SubShader
	{
		// 描画結果をテクスチャに書き込みたいタイミングに応じてQueueを調整する
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass{ "_GrabPassTexture" }

				Pass{

				CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				//float2 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
				half4 grabPos : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			sampler2D _GrabPassTexture;
			float _Amount;
			float _Shift;
			int _Size;

			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
			{
				v2f o = (v2f)0;
				o.vertex = UnityObjectToClipPos(vertex);
				o.normal = UnityObjectToWorldNormal(normal);
				//カメラからオブジェクトのベクトルを求め正規化
				half3 viewDir = normalize(WorldSpaceViewDir(o.vertex));
				//内積を求め、フチに行くほど歪むようにする
				float s = 1 - abs(dot(o.normal, viewDir));
				// GrabPassのテクスチャをサンプリングするUV座標はComputeGrabScreenPosで求める
				o.grabPos = ComputeGrabScreenPos(o.vertex + s * _Shift);


				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//w除算
				float2 uv = float2(i.grabPos.x / i.grabPos.w, i.grabPos.y / i.grabPos.w);
				float3 col;

				//ノイズ
				float x = 2 * uv.y;
				uv.x += _Amount * sin(_Size * x)*(-(x - 1)*(x - 1) + 1);

				//色収差
				col.r = tex2D(_GrabPassTexture, uv).r;
			    col.g = tex2D(_GrabPassTexture, uv - float2(0.004, 0)).g;
			    col.b = tex2D(_GrabPassTexture, uv - float2(0.008, 0)).b;

				return float4(col,1);
			}

				ENDCG
			}
	}
}