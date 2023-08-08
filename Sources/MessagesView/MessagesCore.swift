//
//  MessagesCore.swift
//  
//
//  Created by Douglas Adams on 5/29/23.
//

import ComposableArchitecture
import SwiftUI

import Shared

public struct MessagesFeature: Reducer {
  public init() {}
  
  @AppStorage("alertOnError", store: DefaultValues.flexStore) var alertOnError = false
  @AppStorage("clearOnSend", store: DefaultValues.flexStore) var clearOnSend = false
  @AppStorage("clearOnStart", store: DefaultValues.flexStore) var clearOnStart = false
  @AppStorage("clearOnStop", store: DefaultValues.flexStore) var clearOnStop = false
  @AppStorage("fontSize", store: DefaultValues.flexStore) var fontSize: Double = 12

  @Dependency(\.messagesModel) var messagesModel

  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
    case messagesClear
    case messagesFilter(String)
    case messagesFilterText(String)
    case messagesSave
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      // Parent logic
      switch action {
        
      case .messagesClear:
        messagesModel.clearAll()
        return .none
        
      case let .messagesFilter(filter):
        messagesModel.reFilter(filter: filter)
        return .none
        
      case let .messagesFilterText(filterText):
        messagesModel.reFilter(filterText: filterText)
        return .none
        
      case .messagesSave:
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "Api6000.messages"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save the Log"
        
        let response = savePanel.runModal()
        if response == .OK {
          return .run {_ in 
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 6
            formatter.positiveFormat = " * ##0.000000"
            
            let textArray = messagesModel.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
            let fileTextArray = textArray.joined(separator: "\n")
            try? await fileTextArray.write(to: savePanel.url!, atomically: true, encoding: .utf8)
          }
        } else {
          return .none
        }
      }
    }
  }
}
