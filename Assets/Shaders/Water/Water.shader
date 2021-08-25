// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_WaveSpeed("Wave Speed", Float) = 1
		_WaveTile("Wave Tile", Float) = 1
		_WaveHeight("Wave Height", Float) = 1
		_WaterColour("Water Colour", Color) = (0.2338021,0.5382075,0.6981132,0)
		_TopColour("Top Colour", Color) = (0.2826183,0.6851085,0.8207547,0)
		_EdgeDistance("Edge Distance", Float) = 1
		_EdgePower("Edge Power", Range( 0 , 1)) = 1
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalSpeed("Normal Speed", Float) = 1
		_NormalTile("Normal Tile", Float) = 1
		_NormalStrength("Normal Strength", Range( 0 , 1)) = 1
		_SeaFoam("Sea Foam", 2D) = "white" {}
		_FoamColor("Foam Color", Color) = (1,1,1,0)
		_EdgeFoamTile("Edge Foam Tile", Float) = 1
		_SeaFoamTile("Sea Foam Tile", Float) = 1
		_RefractAmount("Refract Amount", Float) = 0.1
		_Depth("Depth", Float) = -4
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WaveHeight;
		uniform float _WaveSpeed;
		uniform float _WaveTile;
		uniform sampler2D _NormalMap;
		uniform float _NormalSpeed;
		uniform float _NormalTile;
		uniform float _NormalStrength;
		uniform float4 _WaterColour;
		uniform float4 _TopColour;
		uniform sampler2D _SeaFoam;
		uniform float _SeaFoamTile;
		uniform float4 _FoamColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractAmount;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _EdgeDistance;
		uniform float _EdgeFoamTile;
		uniform float _EdgePower;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 Tesselation128 = UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 0.0,80.0,( _WaveHeight * 8.0 ));
			return Tesselation128;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float2 _WaveDirection = float2(-1,0);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float4 WaveTileUV21 = ( ( WorldSpaceTile11 * float4( float2( 0.15,0.02 ), 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( temp_output_7_0 * _WaveDirection + WaveTileUV21.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner23 = ( temp_output_7_0 * _WaveDirection + ( WaveTileUV21 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D24 = snoise( panner23 );
			float temp_output_26_0 = ( simplePerlin2D1 + simplePerlin2D24 );
			float3 WaveHeight31 = ( ( float3(0,1,0) * _WaveHeight ) * temp_output_26_0 );
			v.vertex.xyz += WaveHeight31;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float4 temp_output_74_0 = ( WorldSpaceTile11 / 10.0 );
			float2 panner61 = ( 1.0 * _Time.y * ( float2( 1,0 ) * _NormalSpeed ) + ( temp_output_74_0 * _NormalTile ).xy);
			float2 panner62 = ( 1.0 * _Time.y * ( float2( -1,0 ) * ( _NormalSpeed * 3.0 ) ) + ( temp_output_74_0 * ( _NormalTile * 5.0 ) ).xy);
			float3 Normals71 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner61 ), _NormalStrength ) , UnpackScaleNormal( tex2D( _NormalMap, panner62 ), _NormalStrength ) );
			o.Normal = Normals71;
			float4 FoamColor138 = _FoamColor;
			float2 panner95 = ( 1.0 * _Time.y * float2( 0.04,-0.03 ) + ( WorldSpaceTile11 * 0.03 ).xy);
			float simplePerlin2D94 = snoise( panner95 );
			float4 clampResult101 = clamp( ( ( tex2D( _SeaFoam, ( ( WorldSpaceTile11 / 10.0 ) * _SeaFoamTile ).xy ) * FoamColor138 ) * simplePerlin2D94 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 SeaFoam91 = clampResult101;
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float2 _WaveDirection = float2(-1,0);
			float4 WaveTileUV21 = ( ( WorldSpaceTile11 * float4( float2( 0.15,0.02 ), 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( temp_output_7_0 * _WaveDirection + WaveTileUV21.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner23 = ( temp_output_7_0 * _WaveDirection + ( WaveTileUV21 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D24 = snoise( panner23 );
			float temp_output_26_0 = ( simplePerlin2D1 + simplePerlin2D24 );
			float WavePattern28 = temp_output_26_0;
			float clampResult41 = clamp( WavePattern28 , 0.0 , 1.0 );
			float4 lerpResult39 = lerp( _WaterColour , ( _TopColour + SeaFoam91 ) , clampResult41);
			float4 Albedo42 = lerpResult39;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor109 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( _RefractAmount * Normals71 ) ).xy);
			float4 clampResult110 = clamp( screenColor109 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Refraction111 = clampResult110;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth115 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth115 = abs( ( screenDepth115 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult117 = clamp( ( 1.0 - distanceDepth115 ) , 0.0 , 1.0 );
			float Depth118 = clampResult117;
			float4 lerpResult119 = lerp( Albedo42 , Refraction111 , Depth118);
			o.Albedo = lerpResult119.rgb;
			float screenDepth45 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth45 = abs( ( screenDepth45 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float4 clampResult52 = clamp( ( ( ( 1.0 - distanceDepth45 ) + ( tex2D( _SeaFoam, ( ( WorldSpaceTile11 / 10.0 ) * _EdgeFoamTile ).xy ) * FoamColor138 ) ) * _EdgePower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Edge50 = clampResult52;
			o.Emission = Edge50.rgb;
			o.Smoothness = 0.9;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1135;73;1170;1296;1437.874;2201.799;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;12;-6084.736,-710.9208;Inherit;False;862.9734;330.7729;Comment;3;9;10;11;World Space UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-6034.736,-660.9208;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;10;-5753.686,-633.1478;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-5470.844,-663.0894;Float;False;WorldSpaceTile;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;33;-4812.546,-752.7831;Inherit;False;2524.471;749.6067;Comment;11;15;13;14;17;16;21;19;29;20;30;31;Wave UV's and Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-4762.546,-702.7831;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;15;-4701.298,-449.0559;Float;False;Constant;_WaveStretch;Wave Stretch;2;0;Create;True;0;0;0;False;0;False;0.15,0.02;0.23,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;72;-2903.285,-3724.483;Inherit;False;3059.212;1241.526;Comment;21;56;60;54;57;58;59;65;63;61;66;67;62;64;68;55;36;70;69;71;74;75;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1919.653,-3267.219;Float;False;Property;_NormalSpeed;Normal Speed;8;0;Create;True;0;0;0;False;0;False;1;0.001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2524.502,-3642.899;Float;False;Property;_NormalTile;Normal Tile;9;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-4239.703,-346.4719;Float;False;Property;_WaveTile;Wave Tile;1;0;Create;True;0;0;0;False;0;False;1;-2.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-2853.285,-3649.51;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-4418.5,-574.0662;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;102;-6074.062,-1907.997;Inherit;False;2175.535;893.244;Comment;15;86;89;88;87;90;96;95;94;97;100;85;101;91;142;143;Sea Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2827.562,-3384.259;Float;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-4042.853,-575.0317;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1652.627,-3078.956;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;74;-2585.939,-3386.24;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;63;-1915.811,-3601.482;Float;False;Constant;_PanDirection;Pan Direction;8;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;64;-1898.521,-2786.956;Float;False;Constant;_PanD2;PanD2;8;0;Create;True;0;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2355.869,-3010.094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-5976.316,-1626.424;Float;False;Constant;_Float3;Float 3;12;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-6024.062,-1857.997;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;136;-4200.032,-2697.695;Inherit;False;Property;_FoamColor;Foam Color;12;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.7087932,0.7458291,0.8301887,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;-5675.94,-1804.909;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-5646.894,-1578.383;Float;False;Property;_SeaFoamTile;Sea Foam Tile;14;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-6011.503,-2855.998;Inherit;False;1626.702;633.9205;Comment;10;83;77;79;81;80;76;82;78;140;141;Edge Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-5895.409,-1272.753;Float;False;Constant;_FoamMask;Foam Mask;14;0;Create;True;0;0;0;False;0;False;0.03;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-2185.029,-3594.868;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1460.522,-2767.746;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2081.872,-3018.016;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;34;-4764.861,212.307;Inherit;False;1912.977;1085.222;Comment;13;27;8;6;25;22;5;7;3;23;1;24;26;28;Wave Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-3765.087,-572.7357;Float;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1606.522,-3572.667;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1219.301,-3318.399;Float;False;Property;_NormalStrength;Normal Strength;10;0;Create;True;0;0;0;False;0;False;1;0.177;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-5414.109,-1794.482;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;61;-1322.206,-3674.483;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-4709.467,768.571;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-4482.18,1067.529;Inherit;False;21;WaveTileUV;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-4714.861,996.6224;Float;False;Property;_WaveSpeed;Wave Speed;0;0;Create;True;0;0;0;False;0;False;1;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-5375.339,-2809.814;Float;True;Property;_SeaFoam;Sea Foam;11;0;Create;True;0;0;0;False;0;False;None;c517c6b32e520714ab806e5ebd77ab0a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;-3902.933,-2693.094;Inherit;False;FoamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;54;-2712.567,-3123.029;Float;True;Property;_NormalMap;Normal Map;7;0;Create;True;0;0;0;False;0;False;None;e56f6d3d27b3d114d829c70f8cb68423;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-5626.904,-1276.431;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;62;-1178.127,-2944.481;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-4710.752,262.307;Inherit;False;21;WaveTileUV;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;36;-859.8563,-3497.228;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-4237.01,1038.839;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;85;-5111.765,-1844.424;Inherit;True;Property;_TextureSample3;Texture Sample 3;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;95;-5331.765,-1295.901;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,-0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-4412.798,786.551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-853.7432,-3184.224;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;142;-4788.691,-1739.309;Inherit;False;138;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;5;-4712.158,468.8143;Float;False;Constant;_WaveDirection;Wave Direction;0;0;Create;True;0;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;78;-5961.503,-2611.67;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-4551.124,-1831.404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;3;-4022.059,425.2659;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;23;-4006.708,769.2191;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;94;-5011.143,-1307.695;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;69;-452.4241,-3343.72;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-5936.819,-2418.661;Float;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;-5636.443,-2597.146;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;114;-3351.122,-1752.875;Inherit;False;1787.489;741.2656;Comment;9;105;103;107;106;104;108;109;110;111;Refraction;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-4692.694,-1550.102;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-5607.397,-2370.62;Float;False;Property;_EdgeFoamTile;Edge Foam Tile;13;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-3696.847,423.9471;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;24;-3695.236,763.9899;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-87.07249,-3331.061;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;53;-5332.461,-3692.933;Inherit;False;2217.318;583.2919;Comment;7;50;52;48;47;49;45;46;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;124;-3317.418,-2347.288;Inherit;False;1278.26;332.4771;Comment;5;116;115;123;118;117;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-5279.423,-3627.742;Float;False;Property;_EdgeDistance;Edge Distance;5;0;Create;True;0;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-5374.612,-2586.719;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;103;-3301.122,-1702.875;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-3263.433,-1497.076;Float;False;Property;_RefractAmount;Refract Amount;15;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-3265.523,-1241.61;Inherit;False;71;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;101;-4453.927,-1579.734;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-3390.573,618.3509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-2940.762,-1438.577;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-3267.418,-2297.288;Float;False;Property;_Depth;Depth;16;0;Create;True;0;0;0;False;0;False;-4;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;45;-5004.456,-3622.822;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-3094.886,613.1107;Float;False;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;77;-5014.128,-2676.185;Inherit;True;Property;_TextureSample2;Texture Sample 2;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-4141.527,-1615.257;Float;False;SeaFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;104;-2961.131,-1695.311;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;44;-6500.121,-81.42778;Inherit;False;1485.792;1071.888;Comment;8;42;39;37;38;41;40;92;93;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-4937.804,-2401.874;Inherit;False;138;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;47;-4695.983,-3609.28;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-6435.414,151.2137;Float;False;Property;_TopColour;Top Colour;4;0;Create;True;0;0;0;False;0;False;0.2826183,0.6851085,0.8207547,0;0.2826182,0.6851085,0.8207547,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4675.237,-2416.969;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;115;-3029.194,-2294.641;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;131;-2637.993,236.9716;Inherit;False;1097.959;866.2921;Comment;6;125;130;18;128;126;127;Tesselation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-2621.22,-1523.177;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-6397.555,637.1899;Inherit;False;28;WavePattern;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-6404.111,347.6542;Inherit;False;91;SeaFoam;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2587.993,341.2675;Float;False;Constant;_Tesselation;Tesselation;2;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-4286.412,-3575.551;Float;False;Property;_EdgePower;Edge Power;6;0;Create;True;0;0;0;False;0;False;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3417.213,-255.7164;Float;False;Property;_WaveHeight;Wave Height;2;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-4577.797,-2802.959;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;19;-3394.07,-564.5625;Float;False;Constant;_WaveUp;Wave Up;2;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;123;-2732.239,-2277.76;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;41;-6108.328,563.789;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-6125.854,233.6742;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;37;-6444.325,-36.94292;Float;False;Property;_WaterColour;Water Colour;3;0;Create;True;0;0;0;False;0;False;0.2338021,0.5382075,0.6981132,0;0.233802,0.5382075,0.6981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;109;-2335.903,-1521.053;Float;False;Global;_GrabScreen0;Grab Screen 0;15;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;39;-5845.67,71.80216;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-3097.592,-435.5868;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-2324.169,286.9716;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-2507.877,845.2637;Float;False;Constant;_Float4;Float 4;17;0;Create;True;0;0;0;False;0;False;80;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-3882.132,-3611.138;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;110;-2105.739,-1511.508;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-2521.918,606.8834;Float;False;Constant;_Float2;Float 2;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;117;-2522.419,-2267.811;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-1806.633,-1523.174;Float;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2282.158,-2277.316;Float;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2809.657,-271.6122;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;125;-2124.079,603.2926;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-5529.126,73.45792;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;52;-3641.372,-3606.136;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-825.4019,-1698.436;Inherit;False;111;Refraction;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-826.4424,-1785.037;Inherit;False;42;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2541.541,-272.8209;Float;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;-1783.033,541.8745;Float;False;Tesselation;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-820.0183,-1607.016;Inherit;False;118;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-3364.199,-3619.661;Float;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-821.0551,-1406.038;Inherit;False;50;Edge;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-826.5725,-1088.175;Inherit;False;128;Tesselation;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;119;-543.5716,-1737.228;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-821.8969,-1188.53;Inherit;False;31;WaveHeight;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-824.1559,-1504.855;Inherit;False;71;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-805.7455,-1310.025;Float;False;Constant;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-441.1665,-1455.075;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;1
WireConnection;10;1;9;3
WireConnection;11;0;10;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;67;0;66;0
WireConnection;74;0;56;0
WireConnection;74;1;75;0
WireConnection;59;0;58;0
WireConnection;87;0;86;0
WireConnection;87;1;89;0
WireConnection;57;0;74;0
WireConnection;57;1;58;0
WireConnection;68;0;64;0
WireConnection;68;1;67;0
WireConnection;60;0;74;0
WireConnection;60;1;59;0
WireConnection;21;0;16;0
WireConnection;65;0;63;0
WireConnection;65;1;66;0
WireConnection;90;0;87;0
WireConnection;90;1;88;0
WireConnection;61;0;57;0
WireConnection;61;2;65;0
WireConnection;138;0;136;0
WireConnection;96;0;86;0
WireConnection;96;1;97;0
WireConnection;62;0;60;0
WireConnection;62;2;68;0
WireConnection;36;0;54;0
WireConnection;36;1;61;0
WireConnection;36;5;70;0
WireConnection;25;0;27;0
WireConnection;85;0;76;0
WireConnection;85;1;90;0
WireConnection;95;0;96;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;55;0;54;0
WireConnection;55;1;62;0
WireConnection;55;5;70;0
WireConnection;143;0;85;0
WireConnection;143;1;142;0
WireConnection;3;0;22;0
WireConnection;3;2;5;0
WireConnection;3;1;7;0
WireConnection;23;0;25;0
WireConnection;23;2;5;0
WireConnection;23;1;7;0
WireConnection;94;0;95;0
WireConnection;69;0;36;0
WireConnection;69;1;55;0
WireConnection;81;0;78;0
WireConnection;81;1;82;0
WireConnection;100;0;143;0
WireConnection;100;1;94;0
WireConnection;1;0;3;0
WireConnection;24;0;23;0
WireConnection;71;0;69;0
WireConnection;79;0;81;0
WireConnection;79;1;80;0
WireConnection;101;0;100;0
WireConnection;26;0;1;0
WireConnection;26;1;24;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;45;0;46;0
WireConnection;28;0;26;0
WireConnection;77;0;76;0
WireConnection;77;1;79;0
WireConnection;91;0;101;0
WireConnection;104;0;103;0
WireConnection;47;0;45;0
WireConnection;141;0;77;0
WireConnection;141;1;140;0
WireConnection;115;0;116;0
WireConnection;108;0;104;0
WireConnection;108;1;106;0
WireConnection;83;0;47;0
WireConnection;83;1;141;0
WireConnection;123;0;115;0
WireConnection;41;0;40;0
WireConnection;92;0;38;0
WireConnection;92;1;93;0
WireConnection;109;0;108;0
WireConnection;39;0;37;0
WireConnection;39;1;92;0
WireConnection;39;2;41;0
WireConnection;20;0;19;0
WireConnection;20;1;29;0
WireConnection;130;0;29;0
WireConnection;130;1;18;0
WireConnection;48;0;83;0
WireConnection;48;1;49;0
WireConnection;110;0;109;0
WireConnection;117;0;123;0
WireConnection;111;0;110;0
WireConnection;118;0;117;0
WireConnection;30;0;20;0
WireConnection;30;1;26;0
WireConnection;125;0;130;0
WireConnection;125;1;126;0
WireConnection;125;2;127;0
WireConnection;42;0;39;0
WireConnection;52;0;48;0
WireConnection;31;0;30;0
WireConnection;128;0;125;0
WireConnection;50;0;52;0
WireConnection;119;0;43;0
WireConnection;119;1;120;0
WireConnection;119;2;121;0
WireConnection;0;0;119;0
WireConnection;0;1;73;0
WireConnection;0;2;51;0
WireConnection;0;4;35;0
WireConnection;0;11;32;0
WireConnection;0;14;129;0
ASEEND*/
//CHKSM=D1336D5BCAD9D916E08790AAE5B67F5B28FC2FA4