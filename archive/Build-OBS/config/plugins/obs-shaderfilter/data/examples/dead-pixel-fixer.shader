// Dead Pixel Fixer, Version 0.01, for OBS Shaderfilter
// Copyright ©️ 2022 by SkeletonBow
// License: GNU General Public License, version 2
// Contact info:
//		Twitter: <https://twitter.com/skeletonbowtv>
//		Twitch: <https://twitch.tv/skeletonbowtv>
//
// Description:  Intended for use with an input source that has a dead pixel on its sensor such as a webcam.
// The pixel located at the user configured offset will have its color overridden by taking the average of the
// color of the 8 pixels immediately surrounding it, effectively hiding the dead pixel.
//
// Changelog:
// 0.01	- Initial release

uniform int Dead_Pixel_X<
    string label = "Dead Pixel X";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 2000;
    int step = 1;
> = 0;
uniform int Dead_Pixel_Y<
    string label = "Dead Pixel Y";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 2000;
    int step = 1;
> = 0;

float3 blur_dead_pixel(in float2 pos)
{
	float3 color;
	color = image.Sample(textureSampler,  (pos + float2(-1.0, -0.5))/uv_size).rgb;
	color += image.Sample(textureSampler, (pos + float2(0.5, -1.0))/uv_size).rgb;
	color += image.Sample(textureSampler, (pos + float2(1.0, 0.5))/uv_size).rgb;
	color += image.Sample(textureSampler, (pos + float2(-0.5, 1.0))/uv_size).rgb;
	return color * 0.25;
}

float4 mainImage( VertData v_in ) : TARGET
{
	float2 uv = v_in.uv;
	float2 pos = v_in.pos;
	float2 dp_pos = clamp( float2(Dead_Pixel_X, Dead_Pixel_Y), 0.0, uv_size - 1);
	float4 obstex = image.Sample(textureSampler, uv);
	float3 color;

	if( (uint)pos.x == (uint)dp_pos.x && (uint)pos.y == (uint)dp_pos.y ) {
		color = blur_dead_pixel(pos);
	} else {
		color.rgb = obstex.rgb;
	}
	return float4( color, obstex.a);
}
