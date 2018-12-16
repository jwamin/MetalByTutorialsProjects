//
//  Shaders.metal
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
#include "../Common.h" // path tweak here to allow debugging
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]], constant Uniforms &uniforms [[buffer(1)]]) {
    
    VertexOut vertex_out;
    
    // from vertex position convert to object/model space THEN camera/view space THEN clip space (projection)
    vertex_out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    
    vertex_out.worldPosition = (uniforms.modelMatrix * vertex_in.position).xyz;
    vertex_out.worldNormal = uniforms.normalMatrix * vertex_in.normal;
    vertex_out.point_size = 5.0;
    
    return vertex_out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], constant Light *lights [[buffer(2)]], constant FragmentUniforms &fragmentUniforms [[buffer(3)]]){
    
    float3 specularColor = 0;
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    float3 ambientColor = 0; //resulting ambient color is unset before lights arrive
    float3 baseColor = float3(0,0,1); // base lighting color is BLUE
    float3 diffuseColor = 0; //diffuse will be calculated in loop
    float3 normalDirection = normalize(in.worldNormal); // resize into unit vectors ( length 1 )
    for (uint i = 0; i < fragmentUniforms.lightCount; i++){
        Light light = lights[i];
        if(light.type == Sunlight){
            float3 lightDirection = normalize(light.position);
            float diffuseIntensity = saturate(dot(lightDirection,normalDirection)); // `dot` product, angle from incoming light and reflection of surface normal
            diffuseColor+=light.color * baseColor * diffuseIntensity;
            if (diffuseIntensity > 0) {
                // 1 (R)
                float3 reflection =
                reflect(lightDirection, normalDirection);
                // 2 (V)
                float3 cameraPosition =
                normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                // 3
                float specularIntensity = pow(saturate(dot(reflection, cameraPosition)), materialShininess);
                
                specularColor +=
                light.specularColor * materialSpecularColor * specularIntensity;
            }
        } else if (light.type == Ambientlight){
            ambientColor += light.color * light.intensity;
        }
    }
    float3 color = diffuseColor + ambientColor + specularColor;
    return float4(color,1);
}

fragment float4 secondary(VertexOut in [[stage_in]]){
    return float4(1,0,1,0);
}

//fragment float4 fragment_main(VertexOut in [[stage_in]], constant float4 &color [[buffer(0)]]) {
//    float4 sky = float4(0.34, 0.9, 1.0, 1.0);
//    float4 earth = float4(0.29, 0.58, 0.2, 1.0);
//    float intensity = in.normal.y * 0.5 + 0.5;
//    return mix(earth, sky, intensity);
//}
