// Heat Wave Simple, Version 0.03, for OBS Shaderfilter
// Copyright ©️ 2022 by SkeletonBow
// License: GNU General Public License, version 2
//
// Contact info:
//		Twitter: <https://twitter.com/skeletonbowtv>
//		Twitch: <https://twitch.tv/skeletonbowtv>
//
// Description:
//		Generate a crude pseudo heat wave displacement on an image source.
//
// Based on:  https://www.shadertoy.com/view/td3GRn by Dombass <https://www.shadertoy.com/user/Dombass>
//
// Changelog:
// 0.03 - Added Opacity control
// 0.02 - Added crude Rate, Strength, and Distortion controls
// 0.01	- Initial release

uniform float Rate<
    string label = "Rate";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 5.0;
uniform float Strength<
    string label = "Strength";
    string widget_type = "slider";
    float minimum = -25.0;
    float maximum = 25.0;
    float step = 0.01;
> = 1.0;
uniform float Distortion<
    string label = "Distortion";
    string widget_type = "slider";
    float minimum = 3.0;
    float maximum = 20.0;
    float step = 0.01;
> = 10.0;
uniform float Opacity<
    string label = "Opacity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.01;
> = 100.00;

float4 mainImage( VertData v_in ) : TARGET
{
	float2 uv = v_in.uv;
	float distort = clamp(Distortion, 3.0, 20.0);

    // Time varying pixel color
    float jacked_time = Rate*elapsed_time;
    float2 scale = 0.5;
	float str = clamp(Strength, -25.0, 25.0) * 0.01;
   	
    uv += str * sin(scale*jacked_time + length( uv ) * distort);
	float4 c = image.Sample( textureSampler, uv);
	c.a *= saturate(Opacity*0.01);
    return c;
}
