//
//  ObjectsCore.swift
//  
//
//  Created by Douglas Adams on 5/29/23.
//


import ComposableArchitecture
import SwiftUI

import Shared


public struct ObjectsFeature: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
        .none
    }
  }
}
