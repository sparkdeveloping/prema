//
//  AudioRecorder.swift
//  Trilla
//
//  Created by Medef on 13.12.2022.
//

import AVFoundation

final class AudioRecorder: ObservableObject {

    // MARK: - Public properties
    @Published var samples: [Float] = []
    @Published var recordingTime: TimeInterval = 0
    @Published var isRecording: Bool = false {
        didSet {
            guard oldValue != isRecording else { return }
            if isRecording {
                startRecording()
            } else {
                stopRecording()
            }
        }
    }
    @Published var isFinishRecording: Bool = false
    var audioURL: URL? {
        didSet {
            isFinishRecording = true
        }
    }

    // MARK: - Private properties
    private var audioRecorder: AVAudioRecorder!
    private var decibelLevelTimer = Timer()

    // MARK: - Public methods
    func fetchRecording() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil)
                .filter({ $0.absoluteString.contains(".m4a") })
            let documentPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            // \(Date().getDateString(format: "dd-MM-YY_'at'_HH:mm:ss")
            let lastURL = documentPath
                .appendingPathComponent("\(AccountManager.shared.currentProfile?.id ?? "").m4a")
            audioURL = lastURL
        } catch {
            print(error.localizedDescription)
        }
    }

    func removeRecording() {
        do {
            if let audioURL {
                try FileManager.default.removeItem(at: audioURL)
            }
            isFinishRecording = false
            self.samples.removeAll()
            print("Successfully deleted audio")
        } catch {
            print("File could not be deleted!")
        }
    }

    // MARK: - Private methods
    private func getCreationDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }

    private func startRecording() {
        samples = []

        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }

        let documentPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        // \(Date().getDateString(format: "dd-MM-YY_'at'_HH:mm:ss")
        let audioFilename = documentPath
            .appendingPathComponent("\(AccountManager.shared.currentProfile?.id ?? "").m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            isFinishRecording = false
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
            decibelLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                self.audioRecorder.updateMeters()
                let decibels = self.audioRecorder.averagePower(forChannel: 0)
                let linear = 1 - pow(10, decibels / 20)
                self.recordingTime = self.audioRecorder.currentTime
                self.samples += [linear, linear, linear]
            }
        } catch {
            print("Could not start recording")
        }
    }

    private func stopRecording() {
        audioRecorder.stop()
        recordingTime = .zero
        decibelLevelTimer.invalidate()
        fetchRecording()
    }
}
extension Date {
  func getDateString(format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}
