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
    
    // Called when the STT pubBot (UID 88222) sends transcription data as a JSON stream message
    // JSON format (enableJsonProtocol: true):
    // {"transcript": {"uid": 222, "text": "Hello", "isFinal": false, "offset": ..., "duration": ...}}
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        guard uid == sttBotUid else { return }
        
        print("[STT] Raw stream message received from UID \(uid), size: \(data.count) bytes")
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // Log raw bytes for debugging
            print("[STT] Cannot parse as JSON. Raw: \(data.prefix(100).map { String(format: "%02x", $0) }.joined())")
            return
        }
        
        // Agora JSON format: {"transcript": {"text": "...", "isFinal": true/false}}
        if let transcript = json["transcript"] as? [String: Any] {
            let isFinal = transcript["isFinal"] as? Bool ?? false
            let text = transcript["text"] as? String ?? ""
            
            print("[STT] Transcript — isFinal: \(isFinal), text: \(text)")
            
            if isFinal && !text.isEmpty {
                DispatchQueue.main.async {
                    self.onTranscriptReceived?(text)
                }
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        if uid == sttBotUid {
            print("[STT] Stream message error from pubBot: \(error)")
        }
    }
}
