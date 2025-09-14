//
//  GeometryTypes.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

struct Decomposed<T> {
    let parallel: T
    let perpendicular: T
}

struct Point {
    let x: Float
    let y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    var simd: SIMD2<Float> {
        return SIMD2<Float>(x, y)
    }
}

struct Vector3D {
    let x: Float
    let y: Float  
    let z: Float
    
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ simd: SIMD3<Float>) {
        self.x = simd.x
        self.y = simd.y
        self.z = simd.z
    }
    
    var simd: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
    
    func decompose(onto reference: Vector3D) -> Decomposed<Vector3D> {
        let v = SIMD3<Float>(self)
        let ref = normalize(SIMD3<Float>(reference))
        
        // Project vector onto reference direction
        let parallelComponent = dot(v, ref) * ref
        let perpendicularComponent = v - parallelComponent
        
        return Decomposed(
            parallel: Vector3D(parallelComponent),
            perpendicular: Vector3D(perpendicularComponent)
        )
    }
    
    func projected(onto plane: Plane) -> Vector3D {
        // Decompose this vector onto the plane's normal
        let decomposed = self.decompose(onto: Vector3D(plane.n))
        
        // The perpendicular component lies in the plane
        // Add the plane's offset to get the final projected position
        let planeProjection = decomposed.perpendicular
        return Vector3D(SIMD3<Float>(planeProjection) + plane.offset)
    }
}

extension SIMD3 where Scalar == Float {
    init(_ vector: Vector3D) {
        self.init(vector.x, vector.y, vector.z)
    }
}