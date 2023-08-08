//
//  MessagesView.swift
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct MessagesView: View {
  let store: StoreOf<MessagesFeature>
  @ObservedObject var messagesModel: MessagesModel
  
  public init(store: StoreOf<MessagesFeature>, messagesModel: MessagesModel) {
    self.store = store
    self.messagesModel = messagesModel
  }

  @Namespace var topID
  @Namespace var bottomID
  
  func messageColor(_ text: String) -> Color {
    if text.prefix(1) == "C" { return Color(.systemGreen) }                         // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { return Color(.systemGray) }  // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { return Color(.systemRed) }  // Replies w/error
    if text.prefix(2) == "S0" { return Color(.systemOrange) }                       // S0
    
    return Color(.textColor)
  }
  
  func intervalFormat(_ interval: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 6
    formatter.positiveFormat = " * ##0.000000"
    return formatter.string(from: NSNumber(value: interval))!
  }
  
  public var body: some View {
    
    WithViewStore(self.store, observe: {$0}) { viewStore in
      VStack(alignment: .leading) {
        FilterMessagesView(store: store, messagesModel: messagesModel)
        
        ScrollViewReader { proxy in
          ScrollView([.vertical, .horizontal]) {
            VStack(alignment: .leading) {
              if messagesModel.filteredMessages.count == 0 {
                Text("TCP Message will be displayed here")
              } else {
                Text("Top").hidden()
                  .id(topID)
                ForEach(messagesModel.filteredMessages.reversed(), id: \.id) { message in
                  HStack {
                    if messagesModel.showTimes { Text(intervalFormat(message.interval)) }
                    Text(message.text)
                  }
                  .foregroundColor( messageColor(message.text) )
                }
                Text("Bottom").hidden()
                  .id(bottomID)
              }
            }
            .textSelection(.enabled)
            .font(.system(size: messagesModel.fontSize, weight: .regular, design: .monospaced))
            
            .onChange(of: messagesModel.gotoLast, perform: { _ in
              let id = messagesModel.gotoLast ? bottomID : topID
              proxy.scrollTo(id, anchor: messagesModel.gotoLast ? .bottomLeading : .topLeading)
            })
            .onChange(of: messagesModel.filteredMessages.count, perform: { _ in
              let id = messagesModel.gotoLast ? bottomID : topID
              proxy.scrollTo(id, anchor: messagesModel.gotoLast ? .bottomLeading : .topLeading)
            })
          }
        }
        Spacer()
        Divider()
          .frame(height: 4)
          .background(Color(.gray))
        BottomButtonsView(store: store)
      }
    }
  }
}

private struct FilterMessagesView: View {
  let store: StoreOf<MessagesFeature>
  @ObservedObject var messagesModel: MessagesModel
  
  var body: some View {
    
    WithViewStore(self.store, observe: {$0}) { viewStore in
      HStack {
        Picker("Show Tcp Messages of type", selection: messagesModel.$messageFilter) {
          ForEach(MessagesModel.MessageFilter.allCases, id: \.self) {
            Text($0.rawValue).tag($0.rawValue)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 300)
        
        Image(systemName: "x.circle")
          .onTapGesture {
            messagesModel.messageFilterText = ""
          }

        TextField("filter text", text: messagesModel.$messageFilterText)
      }
    }
    .onChange(of: messagesModel.messageFilter, perform: { messagesModel.reFilter(filter: $0)})
    .onChange(of: messagesModel.messageFilterText, perform: { messagesModel.reFilter(filterText: $0)})
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<MessagesFeature>
  
  @AppStorage("clearOnStart", store: DefaultValues.flexStore) var clearOnStart = false
  @AppStorage("clearOnStop", store: DefaultValues.flexStore) var clearOnStop = false
  @AppStorage("fontSize", store: DefaultValues.flexStore) var fontSize: Double = 12
  @AppStorage("gotoLast", store: DefaultValues.flexStore) public var gotoLast = true

  struct ViewState: Equatable {
    init(state: MessagesFeature.State) {
    }
  }

  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack {
        HStack {
          Text("Go to \(gotoLast ? "Last" : "First")")
          Image(systemName: gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
            .onTapGesture { gotoLast.toggle() }
        }
        Spacer()
        
        HStack {
          Button("Save") { viewStore.send(.messagesSave) }
        }
        Spacer()
        
        HStack(spacing: 30) {
          Toggle("Clear on Start", isOn: $clearOnStart)
          Toggle("Clear on Stop", isOn: $clearOnStop)
          Button("Clear Now") { viewStore.send(.messagesClear)}
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct MessagesView_Previews: PreviewProvider {
  
  static var previews: some View {
    MessagesView(
      store: Store( initialState: MessagesFeature.State()) { MessagesFeature() },
      messagesModel: MessagesModel()
    )
    .frame(minWidth: 975)
    .padding()
  }
}
