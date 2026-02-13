//
//  ContentView.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @State private var collections: [String] = []
    @State private var showCreateNewCollection = false
    @State private var newCollectionName: String = ""
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
            ZStack {
                List {
                    Section {
                        Button {
                            newCollectionName = ""
                            showCreateNewCollection = true
                        } label: {
                            Label("New Collection", systemImage: "plus.circle.fill")
                        }
                    }
        
                    if !collections.isEmpty {
                        Section("Flashcards") {
                            ForEach(collections, id: \.self) { name in
                                Text(name)
                            }
                            .onDelete(perform: deleteCollections)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .sheet(isPresented: $showCreateNewCollection) {
                NavigationStack {
                    Form {
                        Section("Collection Name") {
                            TextField("e.g. World History", text: $newCollectionName)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .focused($isNameFieldFocused)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isNameFieldFocused = true
                                    }
                                }
                            }
                        }
                        .navigationTitle("New Collection")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    showCreateNewCollection = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    saveNewCollection()
                                }
                                .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
        
    }

    private func saveNewCollection() {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        collections.append(trimmed)
        newCollectionName = ""
        showCreateNewCollection = false
    }

    private func deleteCollections(at offsets: IndexSet) {
        collections.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
