﻿Shader "Tecnocampus/WaterShader"
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
		_MaxHeighWater("_MaxHeighWater", Float) = 0.02
		_WaterDirection("_WaterDirection", Vector) = (1.0, 1.0, 1.0, 1.0)
		_SpeedWater("_SpeedWater", Float) = 0.5
		_SpeedWater1("_SpeedWater1", Float) = 0.5
		_DirectionWater1("_DirectionWater1", Vector) = (1.0, 1.0, 1.0, 1.0)
		_SpeedWater2("_SpeedWater2", Float) = 0.5
		_DirectionWater2("_DirectionWater2", Vector) = (1.0, 1.0, 1.0, 1.0)
		_DirectionNoise("_DirectionNoise", Vector) = (1.0, 1.0, 1.0, 1.0)
		_FoamDistance("_FoamDistance", Range(0.0, 1.0)) = 0.5
		_SpeedFoam("_SpeedFoam", Float) = 0.03
		_DirectionFoam("_DirectionFoam", Vector) = (1.0, 1.0, 1.0, 1.0)
		_FoamMultiplier("_FoamMultiplier", Range(0.0, 5.0)) = 2.5
		_FoamCutoff("_FoamCutoff", Range(0.0, 1.0)) = 0.0

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
			float4 _FoamTex_ST;
			sampler2D _NoiseTex;
			sampler2D _WaterHeighMapTex;
			float4 _WaterHeighMapTex_ST;
			float4 _DeepWaterColor;
			float4 _WaterColor;
			float _MaxHeighWater;
			float4 _WaterDirection;
			float _SpeedWater;
			float _SpeedWater1;
			float4 _DirectionWater1;
			float _SpeedWater2;
			float4 _DirectionWater2;
			float4 _DirectionNoise;
			float _FoamDistance;
			float _SpeedFoam;
			float4 _DirectionFoam;
			float _FoamMultiplier;
			float _FoamCutoff;

			v2f MyVS(appdata v)
			{
				v2f o;
				o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));

				/*
				 *	TEMPORAL 
				 *	Mueve el agua entera hacia arriba y hacia abajo
				 *	¿Multiplicar por el noise?
				 */
				// o.vertex.y += sin(v.uv.x + _Time.y*_SpeedWater1)-sin(_Time.y*_SpeedWater2);

				float l_HeightNormalized = tex2Dlod(_WaterHeighMapTex, float4((v.uv * _WaterHeighMapTex_ST.xy) + (_WaterHeighMapTex_ST.zw + _DirectionWater1) * _Time.y * _SpeedWater, 0, 0)).x;
				float l_Height = l_HeightNormalized * _MaxHeighWater + o.vertex.y;
				o.vertex.y = l_Height;

				o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				o.vertex = mul(UNITY_MATRIX_P, o.vertex);

				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 MyPS(v2f i) : SV_Target
			{
				float4 l_Color1 = tex2D(_MainTex, i.uv + (_DirectionWater1.xy + _DirectionWater1.zw) * _Time.y * _SpeedWater1);
				float4 l_Color2 = tex2D(_MainTex, i.uv + (_DirectionWater2.xy + _DirectionWater2.zw) * _Time.y * _SpeedWater2);
				float4 l_DepthColor = tex2D(_WaterDepthTex, i.uv);


				float4 l_Color = l_Color1 * l_Color2;
				
				float l_Depth = l_DepthColor.x;
				if(l_Depth > _FoamDistance)
				{
					float4 l_FoamTex = tex2D(_FoamTex, (i.uv * _FoamTex_ST.xy + (_FoamTex_ST.zw + _DirectionFoam.xy + _DirectionFoam.zw) * _Time.y * _SpeedFoam));
					if(l_Color.x < _FoamCutoff)
						return _WaterColor + 1-( l_FoamTex.x  * _FoamMultiplier);
					return l_Color * (1-l_DepthColor.x)* _DeepWaterColor + (l_DepthColor.x * _WaterColor);
					
				}
				
				return l_Color * (1-l_DepthColor.x) * _DeepWaterColor + (l_DepthColor.x * _WaterColor);
			}
			ENDCG
		}
	}
}
