import SwiftUI

struct DirectCameraScannerView: View {
    @Environment(\.dismiss) private var dismiss

    let onScanCompleted: (_ matchedFood: AppFoodItem?, _ report: IngredientSafetyReport, _ rawText: String) -> Void
    @State private var hasReturnedResult = false
    @State private var recognizedText = ""
    @State private var scanConfidence: Double?
    @State private var scannerID = UUID()

    var body: some View {
        Group {
            if hasReturnedResult {
                OCRReviewView(
                    recognizedText: $recognizedText,
                    confidence: scanConfidence,
                    onRetake: retakeScan,
                    onAnalyze: finishScan,
                    onCancel: { dismiss() }
                )
            } else {
                FoodCameraScannerView { _, _, confidence, rawLabelText in
                    let trimmedRaw = rawLabelText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedRaw.isEmpty else { return }
                    recognizedText = trimmedRaw
                    scanConfidence = confidence
                    hasReturnedResult = true
                }
                .id(scannerID)
                .ignoresSafeArea()
                .background(.black)
                .accessibilityLabel("Scanner")
                .accessibilityHint("Scans ingredient and nutrition labels")
                .accessibilityInputLabels(["Scanner", "Open Scanner", "Tap Scanner"])
            }
        }
    }

    private func retakeScan() {
        Haptics.lightImpact()
        recognizedText = ""
        scanConfidence = nil
        hasReturnedResult = false
        scannerID = UUID()
    }

    private func finishScan() {
        let sourceText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sourceText.isEmpty else { return }
        let report = IngredientSafetyEngine.analyze(labelText: sourceText, scanConfidence: scanConfidence)
        if report.decision == .notAdvised {
            Haptics.warning()
        } else {
            Haptics.success()
        }
        onScanCompleted(nil, report, sourceText)
        dismiss()
    }

}

private struct OCRReviewView: View {
    @Binding var recognizedText: String
    let confidence: Double?
    let onRetake: () -> Void
    let onAnalyze: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                confidenceBanner

                TextEditor(text: $recognizedText)
                    .scaledSystemFont(size: 15, relativeTo: .body)
                    .padding(8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Detected label text")

                HStack(spacing: 12) {
                    Button {
                        onRetake()
                    } label: {
                        Label("Retake", systemImage: "camera.rotate")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        onAnalyze()
                    } label: {
                        Label("Report", systemImage: "doc.text.magnifyingglass")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(16)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Review Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close scanner")
                    .accessibilityHint("Returns to the home screen")
                }
            }
        }
    }

    @ViewBuilder
    private var confidenceBanner: some View {
        if let confidence {
            HStack(spacing: 10) {
                Image(systemName: confidence < 0.65 ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .foregroundStyle(confidence < 0.65 ? .orange : .green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan Confidence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int((confidence * 100).rounded()))%")
                        .font(.headline)
                }

                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
