//
//  AnimeGenerator.swift
//  Anime-fy Yourself
//
//  Created by Yonatan Mittlefehldt on 2021-12-07.
//

import Vision
import CoreImage

class AnimeGenerator: VisionProcessor {
    static let shared = AnimeGenerator()

    private init() {}

    private let requestFast: VNRequest = {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        configuration.allowLowPrecisionAccumulationOnGPU = true
        let model = try! AnimeGANv2_512(configuration: configuration).model
        let req = VNCoreMLRequest(model: try! VNCoreMLModel(for: model))
        req.imageCropAndScaleOption = .centerCrop
        return req
    }()

    private lazy var requestBest: VNRequest = {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        configuration.allowLowPrecisionAccumulationOnGPU = true
        let model = try! AnimeGANv2_1024(configuration: configuration).model
        let req = VNCoreMLRequest(model: try! VNCoreMLModel(for: model))
        req.imageCropAndScaleOption = .centerCrop
        return req
    }()

    private var processing = false

    func process(image: CVPixelBuffer?, fast: Bool) throws -> CIImage? {
        guard let image = image else {
            return nil
        }

        if processing {
            return nil
        }

        processing = true

        defer {
            processing = false
        }

        let request = fast ? requestFast : requestBest
        let animeRequest = try! perform(request, on: image)

        guard let results = animeRequest.results as? [VNPixelBufferObservation],
              let result = results.first else {
                  return nil
              }
        return CIImage(cvPixelBuffer: result.pixelBuffer)
    }
}
