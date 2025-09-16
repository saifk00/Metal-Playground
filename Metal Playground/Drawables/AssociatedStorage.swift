//
//  AssociatedStorage.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation

private var associatedStorageKeyCounter: Int = 0

@propertyWrapper
struct AssociatedStorage<T> {
    private let key: UnsafeRawPointer

    init() {
        // Generate a unique key for each instance
        associatedStorageKeyCounter += 1
        key = UnsafeRawPointer(bitPattern: associatedStorageKeyCounter)!
    }

    static subscript<Instance: AnyObject>(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, T?>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, Self>
    ) -> T? {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return objc_getAssociatedObject(instance, storage.key) as? T
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            objc_setAssociatedObject(instance, storage.key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var wrappedValue: T? {
        get { fatalError("AssociatedStorage only works on instance properties") }
        set { fatalError("AssociatedStorage only works on instance properties") }
    }
}