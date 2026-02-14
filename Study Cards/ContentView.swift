import SwiftUI

struct ContentView: View {
    @State private var collections: [CardCollection] = []
    @State private var showCreateNewCollection = false
    @State private var newCollectionName: String = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var studyCollection: CardCollection? = nil
    @State private var studyMode: StudyMode? = nil
    
    var body: some View {
        NavigationStack {
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
                        ForEach($collections) { $collection in
                            NavigationLink(collection.name) {
                                Flashcard(collection: $collection, startStudying: startStudying)
                            }
                        }
                        .onDelete(perform: deleteCollections)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Study Cards")
            .onAppear {
                loadCollections()
            }
            
            .navigationDestination(isPresented: Binding(
                get: { studyCollection != nil && studyMode != nil },
                set: { if !$0 { studyCollection = nil; studyMode = nil } }
            )) {
                if let collection = studyCollection, let mode = studyMode {
                    Studying(cards: collection.cards, mode: mode)
                }
            }
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
    
    private func startStudying(collection: CardCollection, mode: StudyMode) {
        studyCollection = collection
        studyMode = mode
    }
    
    
    private func loadCollections() {
        do {
            collections = try Persistence.listCollections()
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            print("Loading failed: ", error)
        }
    }
    
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
    
    private func deleteCollections(at offsets: IndexSet) {
        let idsToDelete = offsets.map { collections[$0].id }
        collections.remove(atOffsets: offsets)
        for id in idsToDelete {
            try? Persistence.deleteCollection(id: id)
        }
    }
}
