import Foundation
import AgoraRtcKit
import Combine
import SwiftUI
import AVFoundation

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
    }
    
    func joinChannel(channelName: String, userId: UInt, role: AgoraClientRole = .audience) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone permission granted.")
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
    
    // Called when the STT pubBot (UID 88222) sends transcription data as a stream message
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        guard uid == sttBotUid else { return }
        
        // Try to parse the transcription JSON from Agora STT
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Agora STT v7 format: { "words": [{"text": "...", "isFinal": true}] }
            if let words = json["words"] as? [[String: Any]] {
                let finalWords = words.filter { $0["isFinal"] as? Bool == true }
                let text = finalWords.compactMap { $0["text"] as? String }.joined(separator: " ")
                if !text.isEmpty {
                    print("[STT] Transcript received: \(text)")
                    DispatchQueue.main.async {
                        self.onTranscriptReceived?(text)
                    }
                }
            } else if let text = json["text"] as? String, !text.isEmpty {
                // Alternative flat format
                print("[STT] Transcript received (flat): \(text)")
                DispatchQueue.main.async {
                    self.onTranscriptReceived?(text)
                }
            }
        } else if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            // Plain text fallback
            print("[STT] Transcript received (raw): \(text)")
            DispatchQueue.main.async {
                self.onTranscriptReceived?(text)
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        if uid == sttBotUid {
            print("[STT] Stream message error from pubBot: \(error)")
        }
    }
}
