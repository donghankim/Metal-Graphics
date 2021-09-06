//
//  Renderer.swift
//  metal_graphics
//
//  Created by Donghan Kim on 2021/08/31.
//

import MetalKit
import simd

class objRenderer: NSObject {
    
    var aspect: CGFloat!
    var device: MTLDevice!
    var library: MTLLibrary!
    var pipelineState: MTLRenderPipelineState!
    var vertexDescriptor: MTLVertexDescriptor!
    var MDLMeshes: [MDLMesh]!
    var MTKMeshes: [MTKMesh]!
    var texture: MTLTexture!
    var sampler: MTLSamplerState!
    var uniforms: Uniforms!
    var delta_angle: Int = 0
    
    init(device: MTLDevice, view: MTKView){
        super.init()
        aspect = view.bounds.width / view.bounds.height
        self.device = device
        library = device.makeDefaultLibrary()
        
        self.updateConstants()
        self.setVertexDescriptor()
        self.loadCube()
        self.setPipelineState()
    }
    
    func updateConstants(){
        let worldT = float4x4(scaling: simd_float3(0.7, 0.7, 0.7))
        let viewT = float4x4(translation: simd_float3(0.0, -0.5, 3.0))*float4x4(rotationY: radians(fromDegrees: Float(delta_angle)))
        let projectT = float4x4(projectionFov: radians(fromDegrees: 75), near: 0.1, far: 100, aspect: Float(aspect))
        uniforms = Uniforms(worldMatrix: worldT, viewMatrix: viewT, projectionMatrix: projectT)
        delta_angle += 2
    }
    
    func loadCube(){
        guard let cubeURL = Bundle.main.url(forResource: "cool_car", withExtension: "obj") else { fatalError("Could not load cube obj...") }
        let modelDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        
        let modelPosition = modelDescriptor.attributes[0] as! MDLVertexAttribute
        modelPosition.name = MDLVertexAttributePosition
        
        let modelRGBA = modelDescriptor.attributes[1] as! MDLVertexAttribute
        modelRGBA.name = MDLVertexAttributeColor
        
        let modelTextCoord = modelDescriptor.attributes[2] as! MDLVertexAttribute
        modelTextCoord.name = MDLVertexAttributeTextureCoordinate
        
        let modelNormal = modelDescriptor.attributes[3] as! MDLVertexAttribute
        modelNormal.name = MDLVertexAttributeNormal
        
        // setting model vertex descriptor
        modelDescriptor.attributes[0] = modelPosition
        modelDescriptor.attributes[1] = modelRGBA
        modelDescriptor.attributes[2] = modelTextCoord
        modelDescriptor.attributes[3] = modelNormal
        
        let modelBufferAllocator = MTKMeshBufferAllocator(device: device)
        let cubeAsset = MDLAsset(url: cubeURL, vertexDescriptor: modelDescriptor, bufferAllocator: modelBufferAllocator)
        cubeAsset.loadTextures()
        
        do {
            (MDLMeshes, MTKMeshes) = try MTKMesh.newMeshes(asset: cubeAsset, device: device)
        } catch {
            print("Could not create meshes from obj file")
        }
    }
    
    
    // complete this later
    func loadMaterial(){
        let texture_loader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option : Any] = [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.topLeft]
        
        
    }
    
    // load texture and sampler
    func oldLoader(){
        if let url = Bundle.main.url(forResource: "test", withExtension: "png") {
            let texture_loader = MTKTextureLoader(device: device)
            let options: [MTKTextureLoader.Option : Any] = [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.topLeft]
            
            do {
                texture = try texture_loader.newTexture(URL: url, options: options)
            } catch _ {
                print("got error loading texture")
            }
        } else {
            print("could not find texture")
        }
        
        let sampleDescriptor = MTLSamplerDescriptor()
        sampleDescriptor.minFilter = .linear
        sampleDescriptor.magFilter = .linear
        sampler = device.makeSamplerState(descriptor: sampleDescriptor)
    }
    
    func setVertexDescriptor(){
        vertexDescriptor = MTLVertexDescriptor()
        
        // for position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // for rgba
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 3
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // for tex coord
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<Float>.stride * 7
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        // for normal coord
        vertexDescriptor.attributes[3].format = .float3
        vertexDescriptor.attributes[3].offset = MemoryLayout<Float>.stride * 9
        vertexDescriptor.attributes[3].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 12
    }
    
    func setPipelineState(){
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexShader = library.makeFunction(name: "vertex_shader")
        let fragmentShader = library.makeFunction(name: "fragment_shader")
        descriptor.vertexFunction = vertexShader
        descriptor.fragmentFunction = fragmentShader
        descriptor.vertexDescriptor = vertexDescriptor
    
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
}

 
 
 

