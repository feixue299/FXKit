//
//  Forward.swift
//  FXSwiftX
//
//  Created by aria on 2023/1/17.
//

import Foundation

public protocol ProxyContainer {}

public extension ProxyContainer {
    typealias Forward<Value> = AnyForward<Self, Value>
    typealias GetForward<Value> = ReadForward<Self, Value>
}

extension NSObject: ProxyContainer {}

@propertyWrapper
public struct AnyForward<EnclosingType, Value> {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>
    
    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ValueKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> Value {
        get {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            return instance[keyPath: keyPath]
        }
        set {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            instance[keyPath: keyPath] = newValue
        }
    }
    
    @available(*, unavailable, message: "@Forward can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public let keyPath: ValueKeyPath
    
    public init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }
}

@propertyWrapper
public struct ReadForward<EnclosingType, Value> {
    public typealias ValueKeyPath = KeyPath<EnclosingType, Value>
    public typealias SelfKeyPath = KeyPath<EnclosingType, Self>
    
    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ValueKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> Value {
        get {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            return instance[keyPath: keyPath]
        }
        set {
            
        }
    }
    
    @available(*, unavailable, message: "@Forward can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public let keyPath: ValueKeyPath
    
    public init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }
}
