//
//  Shaders.metal
//  HelloMetal
//
//  Created by Andriy K. on 11/12/16.
//  Copyright © 2016 razeware. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
   float4 position [[position]];
   float4 color;
};

struct FrameSize {
   float x;
   float y;
};

vertex VertexOut basic_vertex (                                         // 1
   const device packed_float3* vertex_array [[ buffer(0) ]],            // 2
   unsigned int vid [[ vertex_id ]]
) {                 // 3
   VertexOut vertexOut;
   vertexOut.position = float4(vertex_array[vid], 1.0);
   vertexOut.color = (vertexOut.position+1)/2;
   return vertexOut;              // 4
}

fragment float4 basic_fragment (
   VertexOut vertexOut [[stage_in]],
   const device FrameSize * frameSize [[ buffer(0) ]]
) { // 1
   //return float4(vertexOut.color);
   return float4((vertexOut.position.x+1)/(frameSize->x),
      1 - (vertexOut.position.y+1)/(frameSize->y), vertexOut.position.z, 1.0);  // 2
}
