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

    enum Field {
        case term, definition
    }

    var startStudying: (CardCollection, StudyMode) -> Void

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
                        Button {
                            startStudying(collection, .termFirst)
                        } label: {
                            Label("Term", systemImage: "book.closed.fill")
                        }

                        Button {
                            startStudying(collection, .definitionFirst)
                        } label: {
                            Label("Description", systemImage: "text.pad.header")
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
            .navigationTitle(collection.name)
    }

    private func addCard() {
        let new = Card(term: term.trimmingCharacters(in: .whitespacesAndNewlines),
                       definition: definition.trimmingCharacters(in: .whitespacesAndNewlines))
        collection.cards.append(new)
        term = ""
        definition = ""
        focusedField = .term
        saveCollection()
    }

    private func deleteCards(at offsets: IndexSet) {
        collection.cards.remove(atOffsets: offsets)
        saveCollection()
    }

    private func saveCollection() {
        do {
            try Persistence.saveCollection(collection)
        } catch {
            print("Save failed:", error)
        }
    }
}

#Preview {
    ContentView()
}
