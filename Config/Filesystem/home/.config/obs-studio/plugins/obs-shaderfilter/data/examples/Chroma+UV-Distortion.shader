//based on https://www.shadertoy.com/view/WsdyRN

//Higher values = less distortion
uniform float distortion<
    string label = "Distortion";
    string widget_type = "slider";
    float minimum = 5.0;
    float maximum = 1000.0;
    float step = 0.01;
> = 75.;
//Higher values = tighter distortion
uniform float amplitude<
    string label = "Amplitude";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.01;
> = 10.;
//Higher values = more color distortion
uniform float chroma<
    string label = "Chroma";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 6.28318531;
    float step = 0.01;
> = .5;

float2 zoomUv(float2 uv, float zoom) {
    float2 uv1 = uv;
    uv1 += .5;
    uv1 += zoom/2.-1.;
    uv1 /= zoom;
    return uv1;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uvt = v_in.uv;
    
    float2 uvtR = uvt;
    float2 uvtG = uvt;
    float2 uvtB = uvt;
    
    //Uncomment the following line to get varying chroma distortion
    //chroma = sin(elapsed_time)/2.+.5;
    
    uvtR += float2(sin(uvt.y*amplitude+elapsed_time)/distortion, cos(uvt.x*amplitude+elapsed_time)/distortion);
    uvtG += float2(sin(uvt.y*amplitude+elapsed_time+chroma)/distortion, cos(uvt.x*amplitude+elapsed_time+chroma)/distortion);
    uvtB += float2(sin(uvt.y*amplitude+elapsed_time+(chroma*2.))/distortion, cos(uvt.x*amplitude+elapsed_time+(chroma*2.))/distortion);
    
    float2 uvR = zoomUv(uvtR, 1.1);
    float2 uvG = zoomUv(uvtG, 1.1);
    float2 uvB = zoomUv(uvtB, 1.1);
    
    float4 colR = image.Sample(textureSampler, uvR);
    float4 colG = image.Sample(textureSampler, uvG);
    float4 colB = image.Sample(textureSampler, uvB);

    return float4(colR.r, colG.g, colB.b, (colR.a + colG.a + colB.a) / 3.0);
}