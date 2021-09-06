//
//  metal_shaders.metal
//  metal_graphics
//
//  Created by Donghan Kim on 2021/08/31.
//

#include <metal_stdlib>

using namespace metal;
#import "common.h"

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textCoord [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textCoord;
};


vertex VertexOut vertex_shader(const VertexIn vIn [[stage_in]],
                               constant Uniforms &uniforms [[ buffer(1) ]],
                               constant float &delta [[ buffer(2) ]]){
    
    VertexOut new_vert;
    new_vert.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.worldMatrix * float4(vIn.position, 1.0);
    new_vert.color = vIn.color;
    new_vert.textCoord = vIn.textCoord;
    return new_vert;
}

fragment float4 fragment_shader(VertexOut vOut [[stage_in]]){
    return vOut.color;
}




