//
//  common.h
//  metal_graphics
//
//  Created by Donghan Kim on 2021/08/31.
//

#ifndef common_h
#define common_h

#import <simd/simd.h>

typedef struct {
  matrix_float4x4 worldMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} Uniforms;

#endif /* common_h */
