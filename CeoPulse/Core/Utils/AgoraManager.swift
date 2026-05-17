import Foundation
import AgoraRtcKit
import Combine
import SwiftUI
import AVFoundation
import Compression

class AgoraManager: NSObject, ObservableObject {
    static let shared = AgoraManager()
    
    // Agora App ID
    private let appId = "15f411d8387c4e5f84e3d41bab1e621d"
    
    @Published var isJoined = false
    @Published var remoteUserIds: Set<UInt> = []
    @Published var isMuted = true
    @Published var isCameraOn = false
    
    private var agoraKit: AgoraRtcEngineKit?
    
    // STT pubBot UID — matches the pubBotUid sent to start-transcription
    private let sttBotUid: UInt = 88222
    
    // Called when the STT bot sends a transcription stream message
    var onTranscriptReceived: ((String) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func setupEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // Default settings for roundtable (Audio first)
        agoraKit?.setChannelProfile(.liveBroadcasting)
        
        // Enable volume indication to monitor audio activity
        agoraKit?.enableAudioVolumeIndication(200, smooth: 3, reportVad: true)
    }
    
    func joinChannel(channelName: String, userId: UInt, role: AgoraClientRole = .audience) {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone permission granted.")
                    do {
                        // Configure AVAudioSession for voice chat
                        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
                        try session.setActive(true, options: .notifyOthersOnDeactivation)
                        print("AVAudioSession category set to playAndRecord and activated successfully.")
                    } catch {
                        print("Failed to configure AVAudioSession: \(error.localizedDescription)")
                    }
                } else {
                    print("Microphone permission denied.")
                }
                self?.performJoinChannel(channelName: channelName, userId: userId, role: role)
            }
        }
    }
    
    private func performJoinChannel(channelName: String, userId: UInt, role: AgoraClientRole) {
        if agoraKit == nil { setupEngine() }
        
        agoraKit?.setClientRole(role)
        
        // Enable audio by default
        agoraKit?.enableAudio()
        
        let options = AgoraRtcChannelMediaOptions()
        options.publishMicrophoneTrack = (role == .broadcaster)
        options.publishCameraTrack = isCameraOn
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true
        options.clientRoleType = role
        
        let result = agoraKit?.joinChannel(byToken: nil, channelId: channelName, uid: userId, mediaOptions: options)
        
        if result == 0 {
            print("Successfully joined channel: \(channelName)")
            isJoined = true
        } else {
            print("Failed to join channel: \(result ?? -1)")
        }
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
        isJoined = false
        remoteUserIds.removeAll()
        AgoraRtcEngineKit.destroy()
        agoraKit = nil
    }
    
    func toggleMute() {
        isMuted.toggle()
        agoraKit?.muteLocalAudioStream(isMuted)
    }
    
    func setMute(_ mute: Bool) {
        isMuted = mute
        agoraKit?.muteLocalAudioStream(mute)
    }
    
    func toggleCamera() {
        isCameraOn.toggle()
        if isCameraOn {
            agoraKit?.enableVideo()
            agoraKit?.startPreview()
        } else {
            agoraKit?.disableVideo()
            agoraKit?.stopPreview()
        }
        agoraKit?.muteLocalVideoStream(!isCameraOn)
    }
    
    func setRole(_ role: AgoraClientRole) {
        agoraKit?.setClientRole(role)
        let options = AgoraRtcChannelMediaOptions()
        options.publishMicrophoneTrack = (role == .broadcaster)
        agoraKit?.updateChannel(with: options)
    }
}

extension AgoraManager: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("[AGORA] Remote user joined channel: UID=\(uid)  (pubBot=88222)")
        DispatchQueue.main.async {
            self.remoteUserIds.insert(uid)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async {
            self.remoteUserIds.remove(uid)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async {
            self.isJoined = true
        }
    }
    
    // Called when the STT pubBot (UID 88222) sends transcription data.
    // Default format is Protobuf; if enableJsonProtocol:true it is gzip-compressed JSON.
    // We handle both: try gzip→JSON first, then raw JSON, then log binary.
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        let firstBytes = data.prefix(4).map { String(format: "%02x", $0) }.joined(separator: " ")
        print("[STT-DIAG] Stream message from UID=\(uid) size=\(data.count) first4=\(firstBytes)")
        
        guard uid == sttBotUid else { return }
        
        // Try to get a JSON-parseable Data object
        let jsonData: Data
        
        // gzip magic bytes: 1f 8b
        let isGzipped = data.count >= 2 && data[0] == 0x1f && data[1] == 0x8b
        
        if isGzipped {
            if let decompressed = gunzip(data) {
                print("[STT] Gzip decompressed OK, size=\(decompressed.count)")
                jsonData = decompressed
            } else {
                print("[STT] Gzip decompression FAILED. Hex: \(data.prefix(20).map { String(format:"%02x",$0) }.joined())")
                return
            }
        } else {
            // Not gzip – try as raw JSON (default Protobuf will fail JSON parse and we log it)
            jsonData = data
        }
        
        // Log raw string for diagnostics
        if let rawStr = String(data: jsonData, encoding: .utf8) {
            print("[STT-RAW] \(rawStr.prefix(400))")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("[STT] Not valid JSON (likely Protobuf). Hex: \(jsonData.prefix(30).map { String(format:"%02x",$0) }.joined())")
            return
        }
        
        if let transcript = json["transcript"] as? [String: Any] {
            let isFinal = transcript["isFinal"] as? Bool ?? false
            let text = transcript["text"] as? String ?? ""
            print("[STT] Transcript — isFinal: \(isFinal), text: \(text)")
            if isFinal && !text.isEmpty {
                DispatchQueue.main.async { self.onTranscriptReceived?(text) }
            }
        } else {
            print("[STT] Unexpected JSON keys: \(json.keys.joined(separator: ", "))")
        }
    }
    
    /// Decompresses gzip-encoded Data using iOS Compression framework.
    private func gunzip(_ data: Data) -> Data? {
        // gzip header is 10 bytes; trailer is 8 bytes
        guard data.count > 18 else { return nil }
        // Strip 10-byte gzip header to get the raw deflate stream
        let deflatePayload = data.subdata(in: 10..<data.count - 8)
        
        // Use a generous output buffer (10× input is usually sufficient)
        let bufferSize = max(data.count * 10, 65536)
        var outputData = Data(count: bufferSize)
        
        let result = outputData.withUnsafeMutableBytes { outPtr -> Int in
            deflatePayload.withUnsafeBytes { inPtr -> Int in
                guard let outBase = outPtr.baseAddress,
                      let inBase = inPtr.baseAddress else { return 0 }
                return compression_decode_buffer(
                    outBase.assumingMemoryBound(to: UInt8.self), bufferSize,
                    inBase.assumingMemoryBound(to: UInt8.self), deflatePayload.count,
                    nil, COMPRESSION_ZLIB
                )
            }
        }
        
        guard result > 0 else { return nil }
        return outputData.prefix(result)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        if uid == sttBotUid {
            print("[STT] Stream message error from pubBot: \(error)")
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        for speaker in speakers {
            if speaker.volume > 0 {
                // Speaker UID 0 is local speaker, or speaker.uid
                print("[AGORA-VOLUME] UID=\(speaker.uid) volume=\(speaker.volume) vad=\(speaker.vad)")
            }
        }
    }
}
