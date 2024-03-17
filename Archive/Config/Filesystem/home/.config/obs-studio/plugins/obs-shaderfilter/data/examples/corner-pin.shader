// Corner Pin, Version 0.1, for OBS Shaderfilter
// Copyright ©️ 2022 by SkeletonBow
// License: GNU General Public License, version 2
// Contact info:
//		Twitter: <https://twitter.com/skeletonbowtv>
//		Twitch: <https://twitch.tv/skeletonbowtv>
//
// Based on:
//		Original work by Inigo Quilez: https://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm
// 			https://www.youtube.com/c/InigoQuilez
//			https://iquilezles.org/
//		and the derivative StreamFX Corner Pin effect by Xaymar
//			https://github.com/Xaymar/obs-StreamFX
//		
// Description:
//		Corner Pin allows you to pin the corners of an image onto the corners of an arbitrarily
//		angled picture frame, TV screen or other rectangular surface in 3D space in an underlying
//		image with proper perspective without distortion.
//
// TODO:
//		- Add feature to automatically quantize corners to pixel centers
//
// Changelog:
// 0.1	- Initial release based on the StreamFX Corner Pin effect, as well as the original work by
//        Inigo Quilez that it was based upon.

uniform bool Antialias_Edges = true;

uniform float Top_Left_X<
    string label = "Top left x";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = -100.;
uniform float Top_Left_Y<
    string label = "Top left y";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = -100.;
uniform float Top_Right_X<
    string label = "Top right x";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.;
uniform float Top_Right_Y<
    string label = "Top right y";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = -100.;
uniform float Bottom_Left_X<
    string label = "Bottom left x";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = -100.;
uniform float Bottom_Left_Y<
    string label = "Bottom left y";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.;
uniform float Bottom_Right_X<
    string label = "Bottom right x";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.;
uniform float Bottom_Right_Y<
    string label = "Bottom right y";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.;

// DEVELOPMENTAL DEBUGGING OPTIONS
//uniform float AAstrength = 1.0;
//uniform float AAdist = 1.0;
//uniform float debug_psmult = 1.0;
//#define PIXEL_SIZE_MULT 2.0

float cross2d(in float2 a, in float2 b)
{
	return (a.x * b.y) - (a.y * b.x);
}

float2 inverse_bilinear(in float2 p, in float2 a, in float2 b, in float2 c, in float2 d)
{
	float2 result = float2(-1., -1.);

	float2 e = b - a;
	float2 f = d - a;
	float2 g = a-b+c-d;
	float2 h = p-a;

	float k2 = cross2d(g, f);
	float k1 = cross2d(e, f) + cross2d(h, g);
	float k0 = cross2d(h, e);

	if (abs(k2) < .001) { // Edges are likely parallel, so this is a linear equation.
		result = float2(
			(h.x * k1 + f.x * k0) / (e.x * k1 - g.x * k0),
			-k0 / k1
		);
	} else { // It's a quadratic equation.
		float w = k1 * k1 - 4.0 * k0 * k2;
		if (w < 0.0) { // Prevent GPUs from going insane.
			return result;
		}
		w = sqrt(w);

		float ik2 = 0.5/k2;
		float v = (-k1 - w) * ik2;
		float u = (h.x - f.x * v) / (e.x + g.x * v);

		if (u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) {
			v = (-k1 + w) * ik2;
			u = (h.x - f.x * v) / (e.x + g.x * v);
		}

		result = float2(u, v);
	}

	return result;
}

// distance to a line segment
float sdSegment( in float2 p, in float2 a, in float2 b )
{
    p -= a; b -= a;
	return length( p-b*saturate(dot(p,b)/dot(b,b)) );
}

// Anti-alias edges - EXPERIMENTAL - (SkeletonBow)
float aastepEdgeAlpha(in float alpha, in float2 p, in float2 a, in float2 b)
{
	//float ps = 2.0 * (2.0/uv_size.y);  // Original
//	float ps = debug_psmult * (2.0/uv_size.y);
	float ps = (2.0/uv_size.y);
//	float ps = fwidth(p)*2.; // Try using fwidth() - goes haywire on AMD Radeon HD7850 at least, disable for now
	return lerp( alpha, 0.0, 1.0 - smoothstep(0.0,ps,sdSegment(p,a,b)));
}

float4 mainImage( VertData v_in ) : TARGET {
	float2 p = 2.* v_in.uv - 1.;
	
	float2 Top_Left = float2(Top_Left_X, Top_Left_Y) * .01;
	float2 Top_Right = float2(Top_Right_X, Top_Right_Y) * .01;
	float2 Bottom_Left = float2(Bottom_Left_X, Bottom_Left_Y) * .01;
	float2 Bottom_Right = float2(Bottom_Right_X, Bottom_Right_Y) * .01;
	
	// Convert from screen coords to potential Quad UV coordinates
	float2 uv = inverse_bilinear(p, Top_Left, Top_Right, Bottom_Right, Bottom_Left);

	if (max(abs(uv.x - .5), abs(uv.y - .5)) >= .5) {
		return float4(0.0, 0.0, 0.0, 0.0);
	}

	float4 texel = image.Sample(textureSampler, uv);

	if ( Antialias_Edges ) {
		// Anti-alias edges of texture
		texel.a = aastepEdgeAlpha(texel.a, p, Top_Left, Top_Right);
		texel.a = aastepEdgeAlpha(texel.a, p, Top_Right, Bottom_Right);
		texel.a = aastepEdgeAlpha(texel.a, p, Bottom_Right, Bottom_Left);
		texel.a = aastepEdgeAlpha(texel.a, p, Bottom_Left, Top_Left);
	}
	return texel;
}
