/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Metal
import UIKit

class ViewController: UIViewController {

  let vertexData:[Float] = [
    0.0, 1.0, 0.9,
    -1.0, -1.0, 0.9,
    1.0, -1.0, 0.9]
    var frameSize:[Float]!
  var device: MTLDevice!
  var metalLayer: CAMetalLayer!
  var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    
  var pipelineState: MTLRenderPipelineState!
  var commandQueue: MTLCommandQueue!
  var timer: CADisplayLink!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    device = MTLCreateSystemDefaultDevice()
    
    metalLayer = CAMetalLayer()          // 1
    metalLayer.device = device           // 2
    metalLayer.pixelFormat = .bgra8Unorm // 3
    metalLayer.framebufferOnly = true    // 4
    metalLayer.frame = view.layer.frame  // 5
    view.layer.addSublayer(metalLayer)   // 6
    
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // 2
    // 1
    let defaultLibrary = device.makeDefaultLibrary()!
    let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
    let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
    
    // 2
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // 3
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
    commandQueue = device.makeCommandQueue()
    
    timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
    timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
  }
    
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      let window = view.window
      if(window == nil) {return}
      let scale = view.window?.screen.nativeScale
      let layerSize = view.bounds.size
      
      frameSize = [Float(layerSize.width * scale!), Float(layerSize.height * scale!)]
      uniformBuffer = device.makeBuffer(bytes: frameSize, 
                                        length: 2*MemoryLayout<Float>.size, options: [])
      
   }
  func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    
   let commandBuffer = commandQueue.makeCommandBuffer()
   let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
   renderEncoder!.setRenderPipelineState(pipelineState)
   renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
   renderEncoder!.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
   renderEncoder!.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
   renderEncoder!.endEncoding()
    
   commandBuffer?.present(drawable)
   commandBuffer?.commit()
  }
  
    @objc func gameloop() {
    autoreleasepool {
      self.render()
    }
  }

}

