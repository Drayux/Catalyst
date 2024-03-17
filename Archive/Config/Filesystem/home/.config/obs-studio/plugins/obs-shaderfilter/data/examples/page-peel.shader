// Simple Page Peel, Version 0.01, for OBS Shaderfilter
// Copyright ©️ 2023 by SkeletonBow
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact info:
//		Twitter: <https://twitter.com/skeletonbowtv>
//		Twitch: <https://twitch.tv/skeletonbowtv>
//		YouTube: <https://youtube.com/@skeletonbow>
//		Soundcloud: <https://soundcloud.com/skeletonbowtv>
//
// Based on Shadertoy shader <https://www.shadertoy.com/view/3s2SzW> by droozle <https://www.shadertoy.com/user/droozle>
//
// Description:
//
//
// Changelog:
// 0.01	- Initial release

uniform float Speed<
    string label = "Speed";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 50.0;
    float step = 0.001;
> = 1.00;
uniform float Position<
    string label = "Position";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.001;
> = 0.0;

float4 mainImage( VertData v_in ) : TARGET
{
    // Normalized pixel coordinates (from 0 to 1)
    float2 aspect = float2( uv_size.x / uv_size.y, 1.0 );
	float2 uv = v_in.uv;

    float t = Position + elapsed_time * Speed;
    // Define the fold.
    float2 origin = float2( 0.6 + 0.4 * sin( t * 0.2 ), 0.5 + 0.5 * cos( t * 0.13 ) ) * aspect;
    float2 normal = normalize( float2( 1.0, 2.0 * sin( t * 0.3 ) ) * aspect );

    // Sample texture.
    float3 col = image.Sample( textureSampler, uv ).rgb; // Front color.
    
    // Check on which side the pixel lies.
    float2 pt = uv * aspect - origin;
    float side = dot( pt, normal );
    if( side > 0.0 ) {
        col *= 0.25; // Background color (peeled off).        
            
        float shadow = smoothstep( 0.0, 0.05, side );
        col = lerp( col * 0.6, col, shadow );
    }
    else {
        // Find the mirror pixel.
        pt = ( uv * aspect - 2.0 * side * normal ) / aspect;
        
        // Check if we're still inside the image bounds.
        if( pt.x >= 0.0 && pt.x < 1.0 && pt.y >= 0.0 && pt.y < 1.0 ) {
            float4 back = image.Sample( textureSampler, pt ); // Back color.
            back.rgb = back.rgb * 0.25 + 0.75;
            
            float shadow = smoothstep( 0.0, 0.2, -side );
            back.rgb = lerp( back.rgb * 0.2, back.rgb, shadow );
            
            // Support for transparency.
            col = lerp( col, back.rgb, back.a );
        }
    }
    
    // Output to screen
    return float4(col,1.0);
}
