Shader "Tecnocampus/WaterShader"
{
	Properties
	{	
		_MainTex("_MainTex", 2D) = "defaulttexture" {}
		_WaterDepthTex("_WaterDepthTex", 2D) = "defaulttexture" {}
		_FoamTex("_FoamTex", 2D) = "defaulttexture" {}
		_NoiseTex("_NoiseTex", 2D) = "defaulttexture" {}
		_WaterHeighMapTex("_WaterHeighMapTex", 2D) = "defaulttexture" {}
		_DeepWaterColor("_DeepWaterColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaterColor("_WaterColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpeedWater1("_SpeedWater1", Float) = 0.5
		_DirectionWater1("_DirectionWater1", Vector) = (1.0, 1.0, 1.0, 1.0)
		_SpeedWater2("_SpeedWater2", Float) = 0.5
		_DirectionWater2("_DirectionWater2", Vector) = (1.0, 1.0, 1.0, 1.0)
		_DirectionNoise("_DirectionNoise", Vector) = (1.0, 1.0, 1.0, 1.0)
		_FoamDistance("_FoamDistance", Range(0.0, 1.0)) = 0.5
		_SpeedFoam("_SpeedFoam", Float) = 0.03
		_DirectionFoam("_DirectionFoam", Vector) = (1.0, 1.0, 1.0, 1.0)
		_FoamMultiplier("_FoamMultiplier", Range(0.0, 5.0)) = 2.5
		_MaxHeighWater("_MaxHeighWater", Float) = 0.02
		_WaterDirection("_WaterDirection", Vector) = (1.0, 1.0, 1.0, 1.0)

	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex MyVS
			#pragma fragment MyPS

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
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaterDepthTex;
			sampler2D _FoamTex;
			sampler2D _NoiseTex;
			sampler2D _WaterHeighMapTex;
			float4 _DeepWaterColor;
			float4 _WaterColor;
			float _SpeedWater1;
			float4 _DirectionWater1;
			float _SpeedWater2;
			float4 _DirectionWater2;
			float4 _DirectionNoise;
			float _FoamDistance;
			float _SpeedFoam;
			float4 _DirectionFoam;
			float _FoamMultiplier;
			float _MaxHeighWater;
			float4 _WaterDirection;

			v2f MyVS(appdata v)
			{
				v2f o;
				o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
				o.vertex.y += _FoamDistance*sin(v.uv.x*_SpeedFoam + _Time.y*_SpeedWater1)-_FoamDistance*sin(_Time.y*_SpeedWater2);
				o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				o.vertex = mul(UNITY_MATRIX_P, o.vertex);

				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 MyPS(v2f i) : SV_Target
			{
				float4 l_Color = tex2D(_MainTex, i.uv);
				return l_Color;
			}
			ENDCG
		}
	}
}
