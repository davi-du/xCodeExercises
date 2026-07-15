//
//  DocumentsView.swift
//  DemoApp
//

import SwiftUI

struct DocumentsView: View {

    @Environment(SessionManager.self) private var session
    @State private var viewModel = DocumentsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.documents.isEmpty {
                    ProgressView("Caricamento...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                } else if viewModel.documents.isEmpty {
                    Text("Nessun documento disponibile.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.documents) { document in
                        NavigationLink(value: document) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(document.title)
                                    .bold()
                                Text(document.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Documenti")
            .navigationDestination(for: DocumentSummary.self) { document in
                DocumentPreviewView(document: document)
            }
            .task {
                guard let token = session.token else { return }
                let ancoraValido = await viewModel.loadDocuments(token: token)
                if !ancoraValido {
                    session.logout()
                }
            }
        }
    }
}

#Preview {
    DocumentsView()
        .environment(SessionManager())
}

