//
//  ViewController.swift
//  metal_graphics
//
//  Created by Donghan Kim on 2021/08/31.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    @IBOutlet var mtkView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var cubeRender: objRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to access GPU")
        }
        mtkView.device = device
        self.device = device
        self.commandQueue = commandQueue
        mtkView.delegate = self
        cubeRender = objRenderer(device: self.device, view: mtkView)
        
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    
    // MARK: - mtkview delegates
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("view size has changed")
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let currentDescriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentDescriptor),
              let renderer = cubeRender
        else {
            fatalError("Error setting up render")
        }
        
        renderer.updateConstants()
    
        commandEncoder.setRenderPipelineState(renderer.pipelineState)
        
        // for vertex constants
        commandEncoder.setVertexBytes(&renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        let mesh = (renderer.cubeMeshes.0.first)!
        let vertexBuffer = mesh.vertexBuffers[0] as! MTLBuffer
        commandEncoder.setVertexBuffer(vertexBuffer, offset: vertexBuffer.heapOffset, index: 0)
        // commandEncoder.drawIndexedPrimitives(submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        
        /*
        for mesh in renderer.cubeMeshes.1 {
            let vertexBuffer = mesh.vertexBuffers[0]
            commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
            
            for submesh in mesh.submeshes {
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
         */
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}

