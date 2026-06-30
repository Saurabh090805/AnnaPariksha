import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @FocusState private var isSearchFocused: Bool
    @State private var showCameraScanner = false
    @State private var scannedFoodItem: AppFoodItem? = nil
    @State private var scanReportState: ScanReportState?
    @State private var showCameraAccessAlert = false
    @State private var showCameraSetupAlert = false
    @State private var showSettingsOpenFailedAlert = false
    @AppStorage("recentFoodIDs") private var recentFoodIDs: String = ""

    private var recentIDs: [UUID] {
        recentFoodIDs
            .split(separator: ",")
            .compactMap { UUID(uuidString: String($0)) }
    }

    private var filteredItems: [AppFoodItem] {
        let filtered = foodItems.filter {
            (selectedCategory == nil || $0.category == selectedCategory) &&
            (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
        }

        if !searchText.isEmpty || selectedCategory != nil {
            return filtered.sorted { $0.name < $1.name }
        }

        let orderMap = Dictionary(uniqueKeysWithValues: recentIDs.enumerated().map { ($1, $0) })
        return filtered.sorted { first, second in
            let firstOrder = orderMap[first.id] ?? Int.max
            let secondOrder = orderMap[second.id] ?? Int.max

            if firstOrder != secondOrder {
                return firstOrder < secondOrder
            }
            if first.category.rawValue != second.category.rawValue {
                return first.category.rawValue < second.category.rawValue
            }
            return first.name < second.name
        }
    }

    private var isSearching: Bool {
        !searchText.isEmpty || selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    topBar
                    headerSection
                    contentSection(for: proxy.size.width)
                }
                .frame(maxWidth: contentMaxWidth(for: proxy.size.width))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showCameraScanner) {
                cameraScannerSheet
            }
            .navigationDestination(item: $scannedFoodItem) { food in
                scannedFoodDestination(for: food)
            }
            .sheet(item: $scanReportState) { state in
                ScanSafetyReportView(report: state.report)
            }
        }
        .tint(.black)
        .onAppear {
            AccessibilitySupport.announce("Home screen. \(filteredItems.count) ingredients shown.")
        }
        .onTapGesture { isSearchFocused = false }
        .onChange(of: filteredItems.count) { _, count in
            AccessibilitySupport.announce("\(count) ingredients shown.")
        }
        .alert("Camera Permission Required", isPresented: $showCameraAccessAlert) {
            Button("Cancel", role: .cancel) {}
            .accessibilityLabel("Cancel")
            .accessibilityInputLabels(["Cancel", "Tap Cancel"])
            Button("Open Settings") {
                Haptics.lightImpact()
                openPreferredSettingsPage()
            }
            .accessibilityLabel("Open Settings")
            .accessibilityInputLabels(["Open Settings", "Tap Open Settings", "Settings"])
        } message: {
            Text("Please allow camera access in Settings to scan ingredients.")
        }
        .alert("Camera Setup Missing", isPresented: $showCameraSetupAlert) {
            Button("OK", role: .cancel) {}
            .accessibilityLabel("OK")
            .accessibilityInputLabels(["OK", "Tap OK"])
        } message: {
            Text("Add Privacy - Camera Usage Description in your target Info settings.")
        }
        .alert("Unable to Open Main Settings", isPresented: $showSettingsOpenFailedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please open Settings manually and allow camera access for AnnaPariksha.")
        }
    }

    private func contentMaxWidth(for width: CGFloat) -> CGFloat {
        min(width, 1180)
    }

    private func gridColumns(for width: CGFloat) -> [GridItem] {
        let availableWidth = min(width, 1180)
        let columnCount: Int

        switch availableWidth {
        case 900...:
            columnCount = 4
        case 640..<900:
            columnCount = 3
        default:
            columnCount = 2
        }

        return Array(
            repeating: GridItem(.flexible(minimum: 150, maximum: 260), spacing: 14),
            count: columnCount
        )
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Text("AnnaPariksha")
                .scaledSystemFont(size: 30, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button {
                handleScanTap()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Scan")
                        .scaledSystemFont(size: 15, weight: .semibold, relativeTo: .callout)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule(style: .continuous)
                                .fill(Color(uiColor: .systemGreen))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(.white.opacity(0.28), lineWidth: 0.6)
                        )
                )
                .shadow(
                    color: Color(uiColor: .systemGreen).opacity(0.25),
                    radius: 6,
                    y: 3
                )
                .clipShape(Capsule())
            }
            .accessibilityLabel("Scan")
            .accessibilityHint("Opens camera to scan packaged food ingredient label")
            .accessibilityInputLabels(["Scan", "Tap Scan", "Open Scan", "Start Scan", "Open Scanner"])
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            SearchBarView(
                searchText: $searchText,
                isFocused: $isSearchFocused
            )
            .padding(.horizontal, 16)

            CategoryFilterView(
                selectedCategory: $selectedCategory
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func contentSection(for width: CGFloat) -> some View {
        if filteredItems.isEmpty && isSearching {
            noResultsView
        } else {
            ScrollView {
                LazyVGrid(columns: gridColumns(for: width), spacing: 14) {
                    ForEach(filteredItems) { item in
                        foodRow(for: item)
                    }
                }
                .padding(.horizontal, width >= 640 ? 24 : 12)
                .padding(.vertical, width >= 640 ? 18 : 10)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.secondary.opacity(0.6))
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No Results for \"\(searchText)\"")
                    .scaledSystemFont(size: 22, weight: .bold, relativeTo: .title3)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Check the spelling or try a new search.")
                    .scaledSystemFont(size: 16, relativeTo: .body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No Results for \(searchText). Check the spelling or try a new search.")
    }

    private var cameraScannerSheet: some View {
        DirectCameraScannerView { _, report, _ in
            Haptics.success()
            scanReportState = ScanReportState(report: report)
        }
    }

    private func handleScanTap() {
        Haptics.lightImpact()
        checkCameraAndOpenScanner()
    }

    private func checkCameraAndOpenScanner() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil else {
            showCameraSetupAlert = true
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            Haptics.mediumImpact()
            showCameraScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        Haptics.mediumImpact()
                        showCameraScanner = true
                    } else {
                        Haptics.warning()
                        showCameraAccessAlert = true
                    }
                }
            }
        case .denied, .restricted:
            Haptics.warning()
            showCameraAccessAlert = true
        @unknown default:
            Haptics.warning()
            showCameraAccessAlert = true
        }
    }

    private func openPreferredSettingsPage() {
        let urlStrings = [
            UIApplication.openSettingsURLString,
            "App-prefs:",
            "Prefs:"
        ]
        openSettingsURL(from: urlStrings, index: 0)
    }

    private func openSettingsURL(from urlStrings: [String], index: Int) {
        guard index < urlStrings.count else {
            showSettingsOpenFailedAlert = true
            return
        }
        guard let url = URL(string: urlStrings[index]) else {
            openSettingsURL(from: urlStrings, index: index + 1)
            return
        }
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened {
                openSettingsURL(from: urlStrings, index: index + 1)
            }
        }
    }

    private func scannedFoodDestination(for food: AppFoodItem) -> some View {
        FoodDetailView(foodItem: food)
            .onAppear {
                addToRecent(food.id)
            }
    }

    private func foodRow(for item: AppFoodItem) -> some View {
        NavigationLink {
            FoodDetailView(foodItem: item)
                .onAppear {
                    addToRecent(item.id)
                }
        } label: {
            FoodCardView(
                foodName: item.name,
                category: categoryLabel(for: item),
                imageName: item.imageName
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { Haptics.lightImpact() })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityValue(categoryLabel(for: item))
        .accessibilityHint("Opens ingredient details")
        .accessibilityInputLabels([item.name, "Tap \(item.name)", "Open \(item.name)"])
    }

    private func categoryLabel(for item: AppFoodItem) -> String {
        return item.category.displayName
    }

    private func addToRecent(_ id: UUID) {
        var current = recentIDs
        current.removeAll { $0 == id }
        current.insert(id, at: 0)
        if current.count > 5 {
            current = Array(current.prefix(5))
        }
        recentFoodIDs = current.map { $0.uuidString }.joined(separator: ",")
    }
}

private struct ScanReportState: Identifiable {
    let id = UUID()
    let report: IngredientSafetyReport
}
