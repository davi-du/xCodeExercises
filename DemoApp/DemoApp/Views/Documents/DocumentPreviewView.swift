//
//  DocumentPreviewView.swift
//  DemoApp
//

import SwiftUI
import PDFKit

struct DocumentPreviewView: View {

    @Environment(SessionManager.self) private var session

    let document: DocumentSummary

    @State private var pdfData: Data?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let pdfData, let pdfDocument = PDFDocument(data: pdfData) {
                PDFKitView(document: pdfDocument)
            } else if isLoading {
                ProgressView("Caricamento del documento...")
            } else {
                Text(errorMessage ?? "Impossibile aprire il documento.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await caricaDocumento()
        }
    }

    private func caricaDocumento() async {
        guard let token = session.token else {
            errorMessage = "Sessione scaduta, accedi di nuovo."
            isLoading = false
            return
        }

        do {
            pdfData = try await CustomerService.fetchDocumentFile(id: document.id, token: token)
        } catch APIError.unauthorized {
            errorMessage = "Sessione scaduta, accedi di nuovo."
            session.logout()
        } catch {
            errorMessage = "Impossibile scaricare il documento."
        }

        isLoading = false
    }
}

private struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = document
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

#Preview {
    NavigationStack {
        DocumentPreviewView(document: DocumentSummary(id: "doc-mario-001", title: "Estratto conto - Giugno 2026", date: Date(), type: "Estratto conto"))
    }
    .environment(SessionManager())
}
