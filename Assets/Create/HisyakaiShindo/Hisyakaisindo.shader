Shader "Custom/Hisyakaisindo"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_MainTex("MainTexture", 2D) = "white" {}
	    _Opacity("Opacity", Range(0.0, 1.0)) = 1.0
        _Offset_R("Offset_R", Range(1.0, 10.0)) = 5.0
		_Offset_B("Offset_B", Range(1.0, 10.0)) = 3.0
		_DepthOffset("DepthOfset", Range(-100, 0)) = 0.0

	}
		SubShader
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
			}
		

//1パス目
		Pass
		{
					Cull Front

			CGPROGRAM
		#pragma target 3.0
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
		};

		sampler2D _CameraDepthTexture;

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 screenPos : TEXCOORD1;
			float3 normal : NORMAL;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Opacity;
		float _Offset_R;
		float _DepthOffset;


		v2f vert(appdata v)
		{
			v2f o;
			v.vertex += float4(v.normal* 0.001f, 0);
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			//スクリーン座標（xy）
			o.screenPos = ComputeScreenPos(o.vertex);
			//カメラから見たデプス(z)を求めるマクロ
			COMPUTE_EYEDEPTH(o.screenPos.z);


			float DepthofWriting = o.screenPos.z + _DepthOffset;
			o.vertex.x += pow(DepthofWriting,2) * 0.0001f * _Offset_R;

			return o;
		}

		fixed4 _Color;


		fixed4 frag(v2f i) : SV_Target
		{
		float partZ = i.screenPos.z;
		//float4 col = tex2D(_MainTex, i.uv);
		//col.a = partZ;
		return float4(1,0,0, _Opacity);
	}
			ENDCG
			}
			


//2パス目
		Pass
		{
					Cull Front

			CGPROGRAM
		#pragma target 3.0
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
		};

		sampler2D _CameraDepthTexture;

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 screenPos : TEXCOORD1;
			float3 normal : NORMAL;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Offset_B;
		float _Opacity;
		float _DepthOffset;


		v2f vert(appdata v)
		{
			v2f o;
			v.vertex += float4(v.normal* 0.001f, 0);
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			//スクリーン座標（xy）
			o.screenPos = ComputeScreenPos(o.vertex);
			//カメラから見たデプス(z)を求めるマクロ
			COMPUTE_EYEDEPTH(o.screenPos.z);

			float DepthofWriting = o.screenPos.z + _DepthOffset;
			o.vertex.x -= pow(DepthofWriting,2) * 0.0001f*_Offset_B;

			return o;
		}

		fixed4 _Color;


		fixed4 frag(v2f i) : SV_Target
		{
		float partZ = i.screenPos.z;
		//float4 col = tex2D(_MainTex, i.uv);
		//col.a = partZ;
		return float4(0,1,0, _Opacity);
	}
			ENDCG
			}



//3パス目
			Pass
		{
			CGPROGRAM
#pragma target 3.0
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 screenPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Offset_R;
			float _Offset_B;
			float _DepthOffset;


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//スクリーン座標（xy）
				o.screenPos = ComputeScreenPos(o.vertex);
				//カメラから見たデプス(z)を求めるマクロ
				COMPUTE_EYEDEPTH(o.screenPos.z);


				return o;
			}

			fixed4 _Color;


			fixed4 frag(v2f i) : SV_Target
			{
			float DepthofWriting = i.screenPos.z + _DepthOffset;

			float R_Offset = pow(DepthofWriting,2) * 0.0001f * _Offset_R;
			float B_Offset = pow(DepthofWriting, 2) * 0.0001f * _Offset_B;

			float4 col = tex2D(_MainTex, i.uv);
			col.r = tex2D(_MainTex, i.uv + float2(R_Offset*0.1f,0));
			col.b = tex2D(_MainTex, i.uv - float2(B_Offset*0.1f,0));
			return col;
			}

	ENDCG
	}
		}
}
