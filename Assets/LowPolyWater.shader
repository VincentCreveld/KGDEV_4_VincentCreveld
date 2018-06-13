Shader "Custom/LowPolyWater" 
{
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_BumpMap("BumMap",2D) = "bump" {}
		_Blend1("Blend between Base and Blend 1 textures", Range(0, 1)) = 0
	}
		SubShader{
			Tags { "RenderType" = "Transperent" "Queue" = "Transparent" }
			ZWrite On
			ColorMask RGBA
			LOD 200
		
			GrabPass{"_GrabPassTex"}

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Lambert vertex:vert

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			float4 _Color;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _GrabPassTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			float3 objectNormal;
			float3 worldRefl;
		};

		void vert(inout appdata_full v, out Input o) 
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);	
			worldPos.x += sin(_Time.z + worldPos.y * 10) * 0.1;
			worldPos.y += cos(_Time.z + worldPos.z * 10) * 0.1;
			worldPos.z += sin(_Time.z + worldPos.x * 10) * 0.1;
			v.vertex = mul(unity_WorldToObject, worldPos);
		}

		float _Blend1;

		void surf (Input IN, inout SurfaceOutput o) {
			//o.Texture = _GrabPassTex;
			

			// Grab pass werkt niet?
			/*
			half3 blue = half3(0, 0, 1);
			half3 norm = lerp(blue, UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)), _Blend1);

			half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.worldRefl);
			
			half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);

			half2 screenUV = IN.screenPos.xy / IN.screenPos.w;

			half3 grabColor = tex2D(_GrabPassTex, screenUV + norm.rg * .01);

			half4 result = half4(lerp(grabColor.rgb, skyColor, fresnel), 1) + pow(fresnel, 8);
			*/
			o.Albedo =  tex2D(_MainTex, IN.uv_MainTex).rgb;//(mainOutput.rgb + blendOutput.rgb);// (c.rgb + d.rgb)*0.5;
			o.Alpha = _Color.a;// mainOutput.a + blendOutput.a;//c.a;

			half3 blue = half3(0, 0, 1);
			o.Normal = lerp(blue, UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + half2(0, _Time.x))), _Blend1);
			half fresnel = 1 - dot(IN.viewDir, o.Normal);
			o.Emission = pow(fresnel, 6);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
