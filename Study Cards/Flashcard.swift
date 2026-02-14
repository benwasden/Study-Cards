//
//  Flashcard.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/11/26.
//

import SwiftUI

struct Flashcard: View {
    @Binding var collection: CardCollection
    @State private var term: String = ""
    @State private var definition: String = ""
    @FocusState private var focusedField: Field?
    @State private var studyCollection: CardCollection? = nil
    @State private var isStudying: Bool = false
    @State private var studyMode: StudyMode = .termFirst
    
    enum Field {
        case term, definition
    }
    
    var body: some View {
        List {
            Section("Add New Card") {
                TextField("Term", text: $term)
                    .focused($focusedField, equals: .term)
                    .textInputAutocapitalization(.words)
                
                TextField("Definition", text: $definition, axis: .vertical)
                    .focused($focusedField, equals: .definition)
                    .textInputAutocapitalization(.sentences)
                
                Button {
                    addCard()
                } label: {
                    Label("Add Card", systemImage: "plus.circle.fill")
                }
                .disabled(term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                          definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            if !collection.cards.isEmpty {
                Section("Study By") {
                    Button("Term") {
                        studyMode = .termFirst
                        isStudying = true
                    }
                    
                    Button("Description") {
                        studyMode = .definitionFirst
                        isStudying = true
                    }.navigationTitle(collection.name)
                        .navigationDestination(isPresented: $isStudying) {
                            Studying(cards: collection.cards, mode: studyMode)
                        }
                }
                    Section("Cards") {
                        ForEach(collection.cards) { card in
                            VStack(alignment: .leading) {
                                Text(card.term).font(.headline)
                                Text(card.definition).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: deleteCards)
                    }
            }
        }
    }
        // Adds a card to the collection for studying. Validates the inputs so users can't
        // enter blank space
        private func addCard() {
            let new = Card(term: term.trimmingCharacters(in: .whitespacesAndNewlines),
                           definition: definition.trimmingCharacters(in: .whitespacesAndNewlines))
            collection.cards.append(new)
            term = ""
            definition = ""
            focusedField = .term
            saveCollection()
        }
        
        // Allows a user to delete a card from a collection
        private func deleteCards(at offsets: IndexSet) {
            collection.cards.remove(atOffsets: offsets)
            saveCollection()
        }
        
        // Saves any changes made from addCard or deleteCards
        private func saveCollection() {
            do {
                try Persistence.saveCollection(collection)
            } catch {
                print("Save failed:", error)
            }
        
    }
    
    #Preview {
        ContentView()
    }
}
