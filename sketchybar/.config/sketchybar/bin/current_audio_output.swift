import CoreAudio
import Foundation

func fourCC(_ value: UInt32) -> String {
    let bytes: [UInt8] = [
        UInt8((value >> 24) & 0xff),
        UInt8((value >> 16) & 0xff),
        UInt8((value >> 8) & 0xff),
        UInt8(value & 0xff)
    ]
    return String(bytes: bytes, encoding: .macOSRoman) ?? "\(value)"
}

func audioDevice(_ selector: AudioObjectPropertySelector) -> AudioDeviceID? {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var device = AudioDeviceID(0)
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &device)
    return status == noErr ? device : nil
}

func uint32Property(_ selector: AudioObjectPropertySelector, object: AudioObjectID) -> UInt32? {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var value = UInt32(0)
    var size = UInt32(MemoryLayout<UInt32>.size)
    let status = AudioObjectGetPropertyData(object, &address, 0, nil, &size, &value)
    return status == noErr ? value : nil
}

let mode = CommandLine.arguments.dropFirst().first ?? "system"
let selector = mode == "output" ? kAudioHardwarePropertyDefaultOutputDevice : kAudioHardwarePropertyDefaultSystemOutputDevice

guard let device = audioDevice(selector) else {
    exit(1)
}

let transport = fourCC(uint32Property(kAudioDevicePropertyTransportType, object: device) ?? 0)

print(transport)
