//
//  ContentView.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @State private var collections: [CardCollection] = []
    @State private var showCreateNewCollection = false
    @State private var newCollectionName: String = ""
    @FocusState private var isNameFieldFocused: Bool

    // The main home view of the app
    var body: some View {
        // Navigation
        NavigationStack {
            List {
                
                // Create a new card collection
                Section {
                    Button {
                        newCollectionName = ""
                        showCreateNewCollection = true
                    } label: {
                        Label("New Collection", systemImage: "plus.circle.fill")
                    }
                }

                // Checks to see if no collections exist already
                // if they do, it displays the second part of the list
                if !collections.isEmpty {
                    Section("Flashcards") {
                        ForEach($collections) { $collection in
                            NavigationLink(collection.name) {
                                Flashcard(collection: $collection)
                            }
                        }
                        // Slide over to left, delete option appears where
                        // deleteCollections function is run
                        .onDelete(perform: deleteCollections)
                    }
                }
            }
            // Styling for list
            .listStyle(.insetGrouped)
            .navigationTitle("Study Cards")
            .onAppear {
                loadCollections()
            }
        }
        // Creating a new collection of cards
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

    // Function calls the listCollections function from the Persistence object(?)/file
    // to load card collections if available
    private func loadCollections() {
        do {
            collections = try Persistence.listCollections()
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            print("Loading failed: ", error)
        }
    }

    // Uses the saveCollection function inside Persistence to save a new collection
    private func saveNewCollection() {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let new = CardCollection(name: trimmed, cards: [])
        
        do {
            try Persistence.saveCollection(new)
        } catch {
            print("Saving failed: ", error)
            return
        }
        
        collections.append(new)
        collections.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        newCollectionName = ""
        showCreateNewCollection = false
    }

    // Deletes a collection
    private func deleteCollections(at offsets: IndexSet) {
        let idsToDelete = offsets.map { collections[$0].id }
        collections.remove(atOffsets: offsets)
        for id in idsToDelete {
            try? Persistence.deleteCollection(id: id)
        }
    }
}

#Preview {
    ContentView()
}
