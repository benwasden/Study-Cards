//
//  Flashcard.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/11/26.
//

import SwiftUI

struct Flashcard: View {
    @State private var collection: CardCollection
    @State private var term: String = ""
    @State private var definition: String = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case term, definition
    }

    init(collection: CardCollection) {
        _collection = State(initialValue: collection)
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
                VStack {
                    Text("Study By").font(.title)
                    HStack {
                        Spacer()
                        NavigationLink {
                            Studying(cards: collection.cards, mode: .termFirst)
                        } label: {
                            Label("Term", systemImage: "book.closed.fill")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                        }

                        Spacer()

                        NavigationLink {
                            Studying(cards: collection.cards, mode: .definitionFirst)
                        } label: {
                            Label("Description", systemImage: "text.pad.header")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                        }
                        
                        Spacer()
                    }
                    .labelStyle(.titleAndIcon)
                    .controlSize(.large)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section("Cards") {
                    ForEach(collection.cards) { card in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(card.term).font(.headline)
                            Text(card.definition).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteCards)
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reloadFromDisk()
        }
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

    private func reloadFromDisk() {
        do {
            collection = try Persistence.loadCollection(id: collection.id)
        } catch {
            print("Load failed:", error)
        }
    }
}

#Preview {
    NavigationStack {
        Flashcard(collection: CardCollection(name: "World History"))
    }
}
