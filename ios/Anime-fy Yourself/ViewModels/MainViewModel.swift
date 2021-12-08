//
//  MainViewModel.swift
//  Anime-fy Yourself
//
//  Created by Yonatan Mittlefehldt on 2021-12-07.
//

import Combine
import CoreImage

class MainViewModel: ObservableObject {
    @Published var error: Error?
    @Published var frame: CGImage?
    @Published var animeFrame: CGImage?
    @Published var displayMode = FrameDisplayMode.original

    private let cameraManager = CameraManager.shared
    private let frameManager = FrameManager.shared

    private let context = CIContext()

    /// Single storage property for `Combine` subscriptions
    private var subscriptions = Set<AnyCancellable>()

    init() {
        setupSubscriptions(fast: true)
    }

    /// Sets up all `Combine` subscriptions in one convenient place
    private func setupSubscriptions(fast: Bool) {
        subscriptions.removeAll()

        setupErrorHandling()

        frameManager.$current
            .compactMap { CGImage.create(from: $0) }
            .assign(to: &$frame)

        frameManager.$current
            .sample(every: 5)
            .compactMap { buffer in
                guard let ciImage = try? AnimeGenerator.shared.process(image: buffer, fast: fast) else {
                    return nil
                }

                return self.context.createCGImage(ciImage, from: ciImage.extent)
            }
            .sink { self.animeFrame = $0 }
            .store(in: &subscriptions)
    }

    /// Sets up subscriptions for error handling `Combine` pipelines
    private func setupErrorHandling() {
        cameraManager.$error
            .receive(on: RunLoop.main)
            .sink { self.error = $0 }
            .store(in: &subscriptions)

        frameManager.$error
            .receive(on: RunLoop.main)
            .sink { self.error = $0 }
            .store(in: &subscriptions)

        // Reset the error after 10 seconds of no new error
        $error
            .debounce(for: .seconds(10), scheduler: DispatchQueue.main)
            .sink { _ in self.error = nil }
            .store(in: &subscriptions)
    }

    /// Cycle through frame display modes
    func nextFrameDisplayMode() {
        DispatchQueue.main.async {
            self.displayMode = self.displayMode.next()
        }
    }
}
