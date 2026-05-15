import Foundation
import AgoraRtcKit

class AgoraManager: NSObject, ObservableObject {
    static let shared = AgoraManager()
    
    // Replace with your Agora App ID
    private let appId = "YOUR_AGORA_APP_ID"
    
    @Published var isJoined = false
    @Published var remoteUserIds: Set<UInt> = []
    @Published var isMuted = true
    @Published var isCameraOn = false
    
    private var agoraKit: AgoraRtcEngineKit?
    
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
        agoraKit?.updateChannelWith(options)
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
}
