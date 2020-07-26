//
//  ARViewControllerContainer.swift
//  RealityComposerTest
//
//  Created by Daniel Dähling on 16.07.20.
//  Copyright © 2020 Daniel Dähling. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARViewControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
}

class ARViewController: UIViewController {
    
    private var arView : ARView!
    private var starScene : StarTest._StarTest!
    private var starScenePure : StarTest.StarPure!
    private var star : Entity!
    private var starPure : Entity!
    
    override func viewDidLoad() {
        arView = ARView()
        arView.frame = view.frame
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        arView.session.delegate = self
        view.addSubview(arView)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking, .resetSceneReconstruction])
        
        StarTest.load_StarTestAsync { [weak self] result in
            guard
                let self = self,
                let starScene = try? result.get(),
                let star = starScene.findEntity(named: "Star")
                else { return }
            
            self.star = star
            self.starScene = starScene
            self.arView.scene.addAnchor(self.starScene)
              
            let boundingBox = star.visualBounds(relativeTo: nil).extents
            let ressource = ShapeResource.generateBox(size: boundingBox)
            star.components.set(CollisionComponent(shapes: [ressource]))
//            star.generateCollisionShapes(recursive: false)
            
            print(starScene)
            print("\n ------------------------------ \n")
            print(starScene.children[0])
            print("\n ------------------------------ \n")
            print(starScene.children[0].children[0])
            print("\n ------------------------------ \n")
            print(starScene.children[0].children[0].children[0])
            print("\n ------------------------------ \n")
            print(starScene.children[0].children[0].children[0].children[0])
        }
        
        StarTest.loadStarPureAsync { [weak self] result in
            guard
                let self = self,
                let starScenePure = try? result.get(),
                let starPure = starScenePure.findEntity(named: "StarPure")
                else { return }
            
            self.starPure = starPure
            self.starPure.isEnabled = false
            self.starScenePure = starScenePure
            self.arView.scene.addAnchor(self.starScenePure)
              
            let boundingBox = starPure.visualBounds(relativeTo: nil).extents
            let ressource = ShapeResource.generateBox(size: boundingBox)
            starPure.components.set(CollisionComponent(shapes: [ressource]))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.arView.scene.anchors.map { $0 as? StarTest._StarTest }.forEach { $0?.notifications.toggleMove.post() }
        //            if let scene = self.arView.scene.anchors[0] as? StarTest.Scene {
        //                print("Scene found!")
        //                scene.notifications.toggleMove.post()
        //            }
                }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? ARView else {
            return
            
        }
        let location = sender.location(in: view)
        guard
            let rayData = arView.ray(through: location),
            let result = arView.scene.raycast(origin: rayData.0, direction: rayData.1).first
            else {
                return
        }

        if result.entity.name == "Star" {
            let transform1 = result.entity.transform
            result.entity.isEnabled = false
            
            starPure.isEnabled = true
            let transform2 = starPure.transform
            starPure.transform = transform1
            var transform3 = transform2
            transform3.translation = SIMD3<Float>(x: 0, y: 0, z: 0)
            transform3.scale = SIMD3<Float>(x: 0, y: 0, z: 0)

            starPure.move(to: transform2, relativeTo: starPure.parent, duration: 0.15, timingFunction: .easeIn)
            starPure.move(to: transform3, relativeTo: starPure.parent, duration: 0.3, timingFunction: .easeOut)
        } else {
            print("Entered else branch")
            let query = ARRaycastQuery(origin: rayData.0, direction: rayData.1, allowing: .existingPlaneInfinite, alignment: .any)
            guard let result = arView.session.raycast(query).first else { return }
            let matrixTranspose = result.worldTransform.transpose
            print("Matrixtranspose: \(matrixTranspose)")
            
            let anchorEntity = AnchorEntity(raycastResult: result)
            arView.scene.addAnchor(anchorEntity)
            
            // Adding a box
//            let boxMesh = MeshResource.generateBox(size: 0.1)
//            let material = SimpleMaterial(color: .blue, isMetallic: false)
//            let box = ModelEntity(mesh: boxMesh, materials: [material])
//            anchorEntity.addChild(box)
//            box.setPosition(.init(x: 0, y: 0.1, z: 0), relativeTo: anchorEntity)
//            let transform = Transform(matrix: matrixTranspose)
            
            // Adding another star
            
            let starCloned = try! StarTest.load_StarTest()
            anchorEntity.addChild(starCloned)
            starCloned.setPosition(.init(x: 0, y: 0, z: 0), relativeTo: anchorEntity)
            starCloned.notifications.toggleMove.post()
//
//            box.setTransformMatrix(matrixTranspose, relativeTo: nil)
//            box.setPosition(.init(x: 0.2, y: 0, z: 0.2), relativeTo: starScene)
//            starScene.addChild(box)

                
                //TODO: Check if an anchor for the result already exists - if not, create it; if yes, refine its position using the updated result
                
        }

    }
 
}


extension ARViewController: ARSessionDelegate {
    
    // Test for Github
    
}
