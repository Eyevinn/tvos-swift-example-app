//
//  HelloXcode.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-10.
//

import Foundation

enum fileReadError: Error {
    case invalidFileUrl(String)
}

@main
enum MyScript {
    static func main() throws {
        guard let projectDir = ProcessInfo.processInfo.environment["SRCROOT"] else {
            print("SRCROOT is undefined")
            return
        }
        let vodXml = (ProcessInfo.processInfo.environment["VOD_XML"]) != nil ? (ProcessInfo.processInfo.environment["VOD_XML"])!.replacingOccurrences(of: "\\", with: "") : nil
        let liveXml = (ProcessInfo.processInfo.environment["LIVE_XML"]) != nil ? (ProcessInfo.processInfo.environment["LIVE_XML"])!.replacingOccurrences(of: "\\", with: "") : nil
        let xmlsIndexed = [vodXml, liveXml].enumerated()
        
        for (index, xmlUrl) in xmlsIndexed {
            let isLive = index == 1 ? true : false
            
            if xmlUrl != nil, xmlUrl!.prefix(7) == "file://" {
                guard let data = NSData(contentsOf: URL(string: xmlUrl!)!) else {
                    throw fileReadError.invalidFileUrl(xmlUrl!)
                }
                
                let bundleFileUrl = URL(string: "file://" + projectDir + (isLive ? "/liveContentCopy.xml" : "/vodContentCopy.xml"))
                do {
                    try data.write(to: bundleFileUrl!)
                    print("Content of file \(xmlUrl!) copied to file: \(bundleFileUrl!.absoluteURL)")
                } catch {
                    // Catch any errors
                    print(error.localizedDescription)
                }
            }
        }
    }
}
