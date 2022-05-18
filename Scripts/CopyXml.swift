//
//  HelloXcode.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-10.
//

import Foundation

@main
enum MyScript {
    static func main() {
        guard let projectDir = ProcessInfo.processInfo.environment["SRCROOT"] else {
            print("SRCROOT is undefined")
            return
        }
        let vodXml = (ProcessInfo.processInfo.environment["VOD_XML"]) != nil ? (ProcessInfo.processInfo.environment["VOD_XML"])!.replacingOccurrences(of: "\\", with: "") : nil
        let liveXml = (ProcessInfo.processInfo.environment["LIVE_XML"]) != nil ? (ProcessInfo.processInfo.environment["LIVE_XML"])!.replacingOccurrences(of: "\\", with: "") : nil
        let xmlsIndexed = [vodXml, liveXml].enumerated()
        
        for (index, xml) in xmlsIndexed {
            let isLive = index == 1 ? true : false

            if xml != nil, xml!.prefix(7) == "file://" {
                let localFilePath = String(xml!.suffix(xml!.count - 7))
                let data = NSData(contentsOfFile: localFilePath)

                if data != nil {
                    let filePath = projectDir + (isLive ? "/liveContentCopy.xml" : "/vodContentCopy.xml")
                    if (FileManager.default.createFile(atPath: filePath, contents: data! as Data, attributes: nil)) {
                        print("File created successfully.")
                    } else {
                        print("File not created.")
                    }
                }
            }
        }
    }
}
