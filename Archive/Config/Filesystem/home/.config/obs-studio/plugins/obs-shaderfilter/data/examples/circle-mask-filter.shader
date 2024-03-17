// Circle Mask Filter version 1.01, for OBS Shaderfilter
// Copyright 2022 by SkeletonBow
//					Twitter: <https://twitter.com/skeletonbowtv>
//					Twitch: <https://twitch.tv/skeletonbowtv>
// License: GNU GPLv2
//
// Changelog:
// 1.01	- Don't saturate() Radius parameter to allow oversizing to cover entire input texture.
// 1.0	- Initial release

uniform float Radius<
    string label = "Radius";
    string widget_type = "slider";
    float minimum = 0;
    float maximum = 100.0;
    float step = 0.01;
> = 50.0;
uniform int Circle_Offset_X<
    string label = "Circle Offset X";
    string widget_type = "slider";
    int minimum = -1000;
    int maximum = 1000;
    int step = 1;
> = 0;
uniform int Circle_Offset_Y<
    string label = "Circle Offset X";
    string widget_type = "slider";
    int minimum = -1000;
    int maximum = 1000;
    int step = 1;
> = 0;
uniform int Source_Offset_X<
    string label = "Source Offset X";
    string widget_type = "slider";
    int minimum = -1000;
    int maximum = 1000;
    int step = 1;
> = 0.0;
uniform int Source_Offset_Y<
    string label = "Source Offset Y";
    string widget_type = "slider";
    int minimum = -1000;
    int maximum = 1000;
    int step = 1;
> = 0.0;

uniform bool Antialiasing = true;
#define Smoothness 100.00
#define AAwidth 4

#define uv_pi uv_pixel_interval

float4 mainImage( VertData v_in ) : TARGET
{
	float2 uv = v_in.uv;
	float2 pos = v_in.pos;
	float2 coffset = float2(Circle_Offset_X, Circle_Offset_Y)/uv_size;
	float2 soffset = float2( Source_Offset_X, Source_Offset_Y )/uv_size;

	float radius = Radius * 0.01;
	float smwidth = radius * Smoothness * 0.01; 
	
	float4 obstex = image.Sample( textureSampler, uv - soffset);
	float4 color = obstex;
	// Account for aspect ratio
	uv.x = (uv.x - 0.5) * uv_size.x / uv_size.y + 0.5;
	float2 cuv = 0.5 + coffset;
	float dist = distance(cuv,uv);
	// Anti-aliased or pixelated edge
	if( Antialiasing ) {
		color.a = smoothstep( radius, (radius+(uv_pi)) - (uv_pi * AAwidth), dist);
	} else {
		color.a = step( dist, radius );
	}

	return float4(color.rgb, color.a);
}
