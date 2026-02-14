//
//  Studying.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/13/26.
//

import SwiftUI

enum StudyMode: String, Codable, CaseIterable, Hashable {
    case termFirst
    case definitionFirst
}

struct Studying: View {
    let cards: [Card]
    let mode: StudyMode

    @State private var index: Int = 0
    @State private var showingFront: Bool = true

    private var isEmpty: Bool { cards.isEmpty }
    private var currentCard: Card? {
        guard !isEmpty, cards.indices.contains(index) else { return nil }
        return cards[index]
    }

    var body: some View {
        VStack(spacing: 20) {
                // Creating the card's face
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.background)
                        .shadow(radius: 4)

                    VStack(spacing: 12) {
                        if let card = currentCard {
                            Text(frontText(for: card))
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: 280)
                .padding(.horizontal)

                // Controls for previous and next card and flipping card over
                HStack(spacing: 16) {
                    Button {
                        previous()
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    .disabled(index == 0)

                    Button {
                        flip()
                    } label: {
                        Label("Flip", systemImage: "arrow.2.squarepath")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        next()
                    } label: {
                        Label("Next", systemImage: "chevron.right")
                    }
                    .buttonStyle(.bordered)
                    .disabled(index >= cards.count - 1)
                }
                .controlSize(.large)
                .padding(.horizontal)

                
                if !isEmpty {
                    Text("Card \(index + 1) of \(cards.count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            
        }
        .navigationTitle(mode == .termFirst ? "Study: Term First" : "Study: Definition First")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Debugging print statement
//            print("Studying appeared with mode ", mode)
            showingFront = true
        }
        .padding(.top)
    }

    // Gets the text for the front of the card when it's displayed. Checks to see
    // if user asked to study by term of by definition before filling it out
    private func frontText(for card: Card) -> String {
        switch mode {
        case .termFirst:
            return showingFront ? card.term : card.definition
        case .definitionFirst:
            return showingFront ? card.definition : card.term
        }
    }

    // Just an animation for the card flipping over so it looks nicer :-)
    private func flip() {
        withAnimation(.easeInOut) {
            showingFront.toggle()
        }
    }

    // Advances forward one card
    private func next() {
        guard index < cards.count - 1 else { return }
        index += 1
        showingFront = true
    }

    // Advances backwards one card
    private func previous() {
        guard index > 0 else { return }
        index -= 1
        showingFront = true
    }
}

#Preview {
    ContentView()
}
