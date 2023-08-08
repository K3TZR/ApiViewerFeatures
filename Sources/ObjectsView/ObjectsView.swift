//
//  ObjectsView.swift
//  
//
//  Created by Douglas Adams on 5/29/23.
//

import ComposableArchitecture
import SwiftUI

import Listener
import FlexApi
import Shared

public enum ObjectFilter: String, CaseIterable {
  case core
  case coreNoMeters = "core w/o meters"
  case amplifiers
  case cwx
  case bandSettings = "band settings"
  case equalizers
  case interlock
  case memories
  case misc
  case profiles
  case meters
  case network
  case streams
  case usbCable
  case wan
  case waveforms
  case xvtrs
}

// ----------------------------------------------------------------------------
// MARK: - View

public struct ObjectsView: View {
  let store: StoreOf<ObjectsFeature>
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var streamModel: StreamModel

  public init(store: StoreOf<ObjectsFeature>, apiModel: ApiModel, objectModel: ObjectModel, streamModel: StreamModel) {
    self.store = store
    self.apiModel = apiModel
    self.objectModel = objectModel
    self.streamModel = streamModel
  }
  
  @AppStorage("fontSize", store: DefaultValues.flexStore) var fontSize: Double = 12
  @AppStorage("isGui", store: DefaultValues.flexStore) var isGui = true

  @Dependency(\.listener) var listener

  public var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      VStack(alignment: .leading) {
        FilterObjectsView(store: store)
        
        ScrollView([.horizontal, .vertical]) {
          VStack(alignment: .leading) {
            if apiModel.radio == nil {
              Text("Objects will be displayed here")
            } else {
              RadioSubView(apiModel: apiModel, objectModel: objectModel, streamModel: streamModel, radio: apiModel.radio!)
              GuiClientSubView(store: store, apiModel: apiModel)
              if isGui == false { TesterSubView() }
            }
          }
        }.font(.system(size: fontSize, weight: .regular, design: .monospaced))
      }.background(Color(.blue).opacity(0.1))
    }
  }
}

private struct FilterObjectsView: View {
  let store: StoreOf<ObjectsFeature>
  
  @AppStorage("objectFilter", store: DefaultValues.flexStore) var objectFilter = ObjectFilter.core.rawValue
  
  var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      HStack {
        Picker("Show Radio Objects of type", selection: $objectFilter ) {
          ForEach(ObjectFilter.allCases, id: \.self) {
            Text($0.rawValue).tag($0.rawValue)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 300)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ObjectsView_Previews: PreviewProvider {

  static var previews: some View {
    ObjectsView(
      store: Store(initialState: ObjectsFeature.State()) { ObjectsFeature() },
      apiModel: ApiModel(),
      objectModel: ObjectModel(),
      streamModel: StreamModel())
    .frame(minWidth: 975)
    .padding()
  }
}
