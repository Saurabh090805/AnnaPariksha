import SwiftUI
import UIKit
import AVFoundation
@preconcurrency import Vision
import ImageIO
import CoreImage

// MARK: - SwiftUI Wrapper
struct FoodCameraScannerView: UIViewControllerRepresentable {
    let onDetect: (_ image: UIImage?, _ detectedObject: String, _ confidence: Double?, _ rawLabelText: String) -> Void

    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let controller = CameraScannerViewController()
        controller.onDetect = onDetect
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraScannerViewController, context: Context) {}
}

// MARK: - Camera Controller
@MainActor
final class CameraScannerViewController: UIViewController {

    var onDetect: ((_ image: UIImage?, _ detectedObject: String, _ confidence: Double?, _ rawLabelText: String) -> Void)?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private let visionQueue = DispatchQueue(label: "in.galgotias.AnnaPariksha.vision", qos: .userInitiated)
    private var isSessionReady = false
    private var didConfigureSession = false
    private let scanState = ScanState()
    private let burstLock = NSLock()
    private var burstRemaining = 0
    private var bestRawText = ""
    private var bestImage: UIImage?
    private var bestConfidence: Double?
    private var isCaptureInProgress: Bool { scanState.isCaptureInProgress }
    private var scanFrameWidthConstraint: NSLayoutConstraint?
    private var didSetInitialScanFrameSize = false

    // MARK: UI
    private let scanFrame: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 22
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.systemGreen.cgColor
        return v
    }()

    private let instructionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Scan packaged-food ingredient label"
        l.textColor = .white
        l.font = UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        l.adjustsFontForContentSizeCategory = true
        l.textAlignment = .center
        l.numberOfLines = 2
        l.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        return l
    }()

    private let captureButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .white
        b.layer.cornerRadius = 35
        b.layer.borderWidth = 5
        b.layer.borderColor = UIColor.systemGreen.cgColor
        b.alpha = 1
        b.isUserInteractionEnabled = true
        return b
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = .label
        return b
    }()

    private let closeButtonGlass: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupOverlayUI()
        configureCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard didConfigureSession, !session.isRunning else { return }
        session.startRunning()
        setSessionReady(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setSessionReady(false)
        if session.isRunning { session.stopRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        if !didSetInitialScanFrameSize {
            scanFrameWidthConstraint?.constant = defaultScanFrameSize()
            didSetInitialScanFrameSize = true
        }
    }

    // MARK: Camera Setup
    private func configureCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    granted ? self.startSession() : self.showCameraSettingsAlert()
                }
            }
        default:
            showCameraSettingsAlert()
        }
    }

    private func startSession() {
#if targetEnvironment(simulator)
        showAlert(title: "Camera Not Available", message: "Run on a real iPhone.")
        return
#else
        if !didConfigureSession {
            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input)
            else {
                showAlert(title: "Camera Error", message: "Camera unavailable.")
                return
            }

            session.beginConfiguration()
            session.sessionPreset = .photo
            session.addInput(input)

            guard session.canAddOutput(photoOutput) else {
                session.commitConfiguration()
                showAlert(title: "Camera Error", message: "Photo output unavailable.")
                return
            }
            session.addOutput(photoOutput)
            if #available(iOS 16.0, *) {
                // iOS 16+ uses maxPhotoDimensions if needed. Default is fine here.
            } else {
                photoOutput.isHighResolutionCaptureEnabled = true
            }

            session.commitConfiguration()
            didConfigureSession = true
        }

        if previewLayer == nil {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            previewLayer = layer
        }

        session.startRunning()
        setSessionReady(true)
#endif
    }

    // MARK: UI Layout
    private func setupOverlayUI() {
        scanFrame.isUserInteractionEnabled = true
        scanFrame.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(resizeScanFrame(_:))))

        view.addSubview(scanFrame)
        view.addSubview(instructionLabel)
        view.addSubview(captureButton)
        view.addSubview(closeButtonGlass)
        view.addSubview(closeButton)

        let widthConstraint = scanFrame.widthAnchor.constraint(equalToConstant: 0)
        scanFrameWidthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            scanFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            widthConstraint,
            scanFrame.heightAnchor.constraint(equalTo: scanFrame.widthAnchor),

            instructionLabel.bottomAnchor.constraint(equalTo: scanFrame.topAnchor, constant: -20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalToConstant: 300),
            instructionLabel.heightAnchor.constraint(equalToConstant: 56),

            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),

            closeButtonGlass.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButtonGlass.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButtonGlass.widthAnchor.constraint(equalToConstant: 40),
            closeButtonGlass.heightAnchor.constraint(equalToConstant: 40),

            closeButton.topAnchor.constraint(equalTo: closeButtonGlass.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: closeButtonGlass.leadingAnchor),
            closeButton.widthAnchor.constraint(equalTo: closeButtonGlass.widthAnchor),
            closeButton.heightAnchor.constraint(equalTo: closeButtonGlass.heightAnchor)
        ])

        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeScanner), for: .touchUpInside)
    }

    // MARK: Actions
    @objc private func resizeScanFrame(_ gesture: UIPinchGestureRecognizer) {
        guard let widthConstraint = scanFrameWidthConstraint else { return }
        let maxSize = max(180, min(view.bounds.width - 32, view.bounds.height - 220))
        let newSize = min(max(widthConstraint.constant * gesture.scale, 180), maxSize)
        widthConstraint.constant = newSize
        gesture.scale = 1
    }

    @objc private func capturePhoto() {
        guard isSessionReady, scanState.beginCapture() else { return }
        burstLock.lock()
        burstRemaining = 1
        bestRawText = ""
        bestImage = nil
        bestConfidence = nil
        burstLock.unlock()
        updateCaptureButtonAvailability()

        captureOnce()
    }

    private func captureOnce() {
        let settings = AVCapturePhotoSettings()
        if #available(iOS 16.0, *) {
            // Keep default dimensions for broad compatibility.
        } else {
            settings.isHighResolutionPhotoEnabled = true
        }
        if #available(iOS 13.0, *) {
            settings.photoQualityPrioritization = photoOutput.maxPhotoQualityPrioritization
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func closeScanner() {
        if session.isRunning { session.stopRunning() }
        dismiss(animated: true)
    }

    private func setSessionReady(_ ready: Bool) {
        isSessionReady = ready
        updateCaptureButtonAvailability()
    }

    private func updateCaptureButtonAvailability() {
        let canCapture = isSessionReady && !isCaptureInProgress
        captureButton.isUserInteractionEnabled = canCapture
        captureButton.alpha = canCapture ? 1 : 0.5
    }

    private func defaultScanFrameSize() -> CGFloat {
        let maxSize = max(180, min(view.bounds.width - 32, view.bounds.height - 220))
        return min(max(view.bounds.width * 0.78, 220), maxSize)
    }

    @MainActor
    private func finishBurst(with image: UIImage?, rawText: String, confidence: Double?) {
        burstLock.lock()
        if !rawText.isEmpty && rawText.count > bestRawText.count {
            bestRawText = rawText
            bestImage = image
            bestConfidence = confidence
        }
        if burstRemaining > 0 {
            burstRemaining -= 1
        }
        let shouldFinish = burstRemaining == 0
        let finalText = bestRawText
        let finalImage = bestImage
        let finalConfidence = bestConfidence
        burstLock.unlock()

        guard shouldFinish else { return }
        scanState.endCapture()
        updateCaptureButtonAvailability()

        let trimmed = finalText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showAlert(
                title: "No Label Text Found",
                message: "Try again with better light and keep the label inside the frame."
            )
            return
        }
        guard IngredientSafetyEngine.looksLikeNutritionLabel(finalText) else {
            showAlert(
                title: "No Food Label Found",
                message: "Point the camera at the ingredients or nutrition section of the package."
            )
            return
        }
        if session.isRunning { session.stopRunning() }
        onDetect?(finalImage, "", finalConfidence, finalText)
    }

    @MainActor
    private func normalizedScanRect() -> CGRect? {
        guard let previewLayer else { return nil }
        var rect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanFrame.frame)
        rect = rect.insetBy(dx: -0.02, dy: -0.02)
        rect.origin.x = max(0, rect.origin.x)
        rect.origin.y = max(0, rect.origin.y)
        rect.size.width = min(1 - rect.origin.x, rect.size.width)
        rect.size.height = min(1 - rect.origin.y, rect.size.height)
        return rect
    }

    // MARK: Alerts
    private func showCameraSettingsAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Enable camera access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Photo Delegate
extension CameraScannerViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.finishBurst(with: nil, rawText: "", confidence: nil)
                self.showAlert(title: "Capture Failed", message: "Please try again.")
            }
            return
        }

        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        Task.detached { [weak self] in
            guard let self else { return }
            let roi = await MainActor.run { self.normalizedScanRect() }

            let ocrResult = Self.recognizeText(from: cgImage, orientation: orientation, roi: roi)
            var rawText = ocrResult.text
            var bestConfidence = ocrResult.confidence
            var bestScore = rawText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count

            if let boosted = Self.enhancedCGImage(from: cgImage, orientation: orientation, roi: roi) {
                let boostedResult = Self.recognizeText(from: boosted, orientation: .up, roi: nil)
                let score = boostedResult.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count
                if score > bestScore {
                    bestScore = score
                    rawText = boostedResult.text
                    bestConfidence = boostedResult.confidence
                }
            }

            if let highContrast = Self.highContrastCGImage(from: cgImage, orientation: orientation, roi: roi) {
                let highContrastResult = Self.recognizeText(from: highContrast, orientation: .up, roi: nil)
                let score = highContrastResult.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count
                if score > bestScore {
                    rawText = highContrastResult.text
                    bestConfidence = highContrastResult.confidence
                }
            }
            let trimmed = rawText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let finalRawText = trimmed.isEmpty ? "" : rawText
            let finalConfidence = bestConfidence

            await MainActor.run {
                self.finishBurst(with: image, rawText: finalRawText, confidence: finalConfidence)
            }
        }
    }
}

// MARK: - Live OCR Delegate
private final class ScanState: @unchecked Sendable {
    private let lock = NSLock()
    nonisolated(unsafe) private var isCapturing = false

    nonisolated init() {}

    nonisolated var isCaptureInProgress: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isCapturing
    }

    nonisolated func beginCapture() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if isCapturing { return false }
        isCapturing = true
        return true
    }

    nonisolated func endCapture() {
        lock.lock()
        isCapturing = false
        lock.unlock()
    }
}

private struct OCRRecognitionResult {
    let text: String
    let confidence: Double
}

private extension CameraScannerViewController {
    nonisolated static let ciContext = CIContext()

    nonisolated static func enhancedCGImage(from cgImage: CGImage, orientation: CGImagePropertyOrientation, roi: CGRect?) -> CGImage? {
        let oriented = CIImage(cgImage: cgImage).oriented(orientation)
        let baseImage: CIImage
        if let roi {
            guard let cropped = crop(ciImage: oriented, roi: roi) else { return nil }
            baseImage = cropped
        } else {
            baseImage = oriented
        }
        let controls = baseImage.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: 1.4,
            kCIInputSaturationKey: 0.0,
            kCIInputBrightnessKey: 0.05
        ])
        let sharpened = controls.applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: 0.6
        ])
        return ciContext.createCGImage(sharpened, from: sharpened.extent)
    }

    nonisolated static func highContrastCGImage(from cgImage: CGImage, orientation: CGImagePropertyOrientation, roi: CGRect?) -> CGImage? {
        let oriented = CIImage(cgImage: cgImage).oriented(orientation)
        let baseImage: CIImage
        if let roi {
            guard let cropped = crop(ciImage: oriented, roi: roi) else { return nil }
            baseImage = cropped
        } else {
            baseImage = oriented
        }
        let noir = baseImage.applyingFilter("CIPhotoEffectNoir", parameters: [:])
        let exposure = noir.applyingFilter("CIExposureAdjust", parameters: [
            kCIInputEVKey: 0.7
        ])
        let sharpened = exposure.applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: 0.8
        ])
        return ciContext.createCGImage(sharpened, from: sharpened.extent)
    }

    nonisolated static func recognizeText(from cgImage: CGImage, orientation: CGImagePropertyOrientation, roi: CGRect?) -> OCRRecognitionResult {
        let baseImage: CGImage
        if let roi {
            guard let cropped = crop(cgImage: cgImage, orientation: orientation, roi: roi) else {
                return OCRRecognitionResult(text: "", confidence: 0)
            }
            baseImage = cropped
        } else if orientation != .up,
                  let oriented = crop(cgImage: cgImage, orientation: orientation, roi: nil) {
            baseImage = oriented
        } else {
            baseImage = cgImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        request.minimumTextHeight = 0.008
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        }

        let handler = VNImageRequestHandler(cgImage: baseImage, orientation: .up, options: [:])
        do {
            try handler.perform([request])
            let observations = request.results ?? []
            let results = observations.compactMap { $0.topCandidates(1).first }
            let text = results.map(\.string).joined(separator: "\n")
            let confidence = results.isEmpty
            ? 0
            : Double(results.map(\.confidence).reduce(0, +)) / Double(results.count)
            return OCRRecognitionResult(text: text, confidence: confidence)
        } catch {
            return OCRRecognitionResult(text: "", confidence: 0)
        }
    }

    nonisolated static func crop(cgImage: CGImage, orientation: CGImagePropertyOrientation, roi: CGRect?) -> CGImage? {
        let oriented = CIImage(cgImage: cgImage).oriented(orientation)
        let base: CIImage
        if let roi {
            guard let cropped = crop(ciImage: oriented, roi: roi) else { return nil }
            base = cropped
        } else {
            base = oriented
        }
        return ciContext.createCGImage(base, from: base.extent)
    }

    nonisolated static func crop(ciImage: CIImage, roi: CGRect?) -> CIImage? {
        guard let roi else { return nil }
        let clampedX = max(0, roi.origin.x)
        let clampedY = max(0, roi.origin.y)
        let clampedWidth = min(1 - clampedX, roi.width)
        let clampedHeight = min(1 - clampedY, roi.height)
        guard clampedWidth > 0, clampedHeight > 0 else { return nil }
        let clamped = CGRect(x: clampedX, y: clampedY, width: clampedWidth, height: clampedHeight)
        let extent = ciImage.extent
        let x = clamped.origin.x * extent.width
        let y = (1 - clamped.origin.y - clamped.height) * extent.height
        let rect = CGRect(x: x, y: y, width: clamped.width * extent.width, height: clamped.height * extent.height)
        let validRect = rect.intersection(extent)
        guard !validRect.isNull, validRect.width > 0, validRect.height > 0 else { return nil }
        return ciImage.cropped(to: validRect)
    }
}

private extension CGImagePropertyOrientation {
    nonisolated init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

// MARK: - Preview
