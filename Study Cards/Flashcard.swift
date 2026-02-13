//
//  Flashcard.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/13/26.
//

import SwiftUI

struct Flashcard: View {
    let collectionName: String

    var body: some View {
        VStack(spacing: 16) {
            Text(collectionName)
                .font(.title)
                .bold()
            Text("Add cards UI goes here")
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle(collectionName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        Flashcard(collectionName: "World History")
    }
}
