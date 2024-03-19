// Opacity shader - for OBS Shaderfilter
// Copyright 2021 by SkeltonBowTV
// https://twitter.com/skeletonbowtv
// https://twitch.tv/skeletonbowtv

uniform float Opacity<
    string label = "Opacity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 200.0;
    float step = 0.01;
> = 100.00; // 0.00 - 100.00 percent

float4 mainImage( VertData v_in ) : TARGET
{
	float4 color = image.Sample( textureSampler, v_in.uv );
	return float4( color.rgb, color.a * Opacity * 0.01 );
}