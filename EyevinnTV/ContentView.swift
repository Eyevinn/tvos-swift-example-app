//
//  ContentView.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-03.
//

import SwiftUI
import SWXMLHash

class videoURLObject: ObservableObject {
    @Published var currentVideoURL = ""
    @Published var currentVideoTitle = ""
}

struct ContentView: View {
    @State var videoItems = [Item]()
    @State var liveVideoItems = [Item]()
    @StateObject var outerVideoURLObject = videoURLObject()

    private var urlXmlVod = "https://testcontent.mrss.eyevinn.technology/"
    private let localXmlVod = "testContent"
    private let localXmlLive = "liveTestContent"
    
    private var readLocal = false
    
    var body: some View {
        NavigationView {
            if outerVideoURLObject.currentVideoURL == "" {
                VStack{
                    Image("eyevinn-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200, alignment: .center)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(videoItems) { item in
                                VStack {
                                    Button {
                                        outerVideoURLObject.currentVideoURL = item.videoURL
                                        outerVideoURLObject.currentVideoTitle = item.title
                                        print(item.videoURL) } label: {
                                            VStack {
                                                Image(systemName: "play.tv")
                                                    .font(.system(size: 100))
                                                Text("\(item.title)")
                                                    .bold()
                                            }
                                            .frame(width: 550, height: 250)
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(liveVideoItems) { item in
                                VStack {
                                    Button {
                                        outerVideoURLObject.currentVideoURL = item.videoURL
                                        outerVideoURLObject.currentVideoTitle = item.title
                                        print(item.videoURL) } label: {
                                            VStack {
                                                Image(systemName: "play.tv")
                                                    .font(.system(size: 100))
                                                Text("\(item.title)")
                                                    .bold()
                                            }
                                            .frame(width: 550, height: 250)
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    .focusSection()
                }
            } else {
                VideoView(innerURLObject: outerVideoURLObject)
            }
        }
        .onAppear() {
            loadData()
        }
    }
    
    func parseXML(feed: String, isLive: Bool) {
        let xml = SWXMLHash.parse(feed)
        
        for elem in xml["feed"]["entry"].all
        {
            let item = Item()
            item.title = elem["title"].element!.text
            item.id = elem["id"].element!.text
            item.videoURL = elem["link"].element!.text
            isLive ? liveVideoItems.append(item) : videoItems.append(item)
        }
    }
    
    func loadData() {
        if readLocal {
            let xmlPath = Bundle.main.path(forResource: localXmlVod, ofType: "xml")
            let data = NSData(contentsOfFile: xmlPath!)
            
            if data != nil
            {
                let feed = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
                parseXML(feed: feed, isLive: false)
            }
        }
        
        else {
            let url = NSURL(string: urlXmlVod)
            let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
                if data != nil
                {
                    let feed = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                    parseXML(feed: feed, isLive: false)
                }
            }
            task.resume()
        }
        
        let xmlPath = Bundle.main.path(forResource: localXmlLive, ofType: "xml")
        let data = NSData(contentsOfFile: xmlPath!)

        if data != nil
        {
            let feed = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
            parseXML(feed: feed, isLive: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
