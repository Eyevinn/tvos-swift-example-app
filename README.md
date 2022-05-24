# Eyevinn tvOS Example App
The Eyevinn tvOS Example App is a simple Apple TV app that loads two XML files/MRSS feeds, displays their contents for selection, and plays back the linked HLS manifest of the selected entry. The XML files/MRSS feeds may be either remote files loaded during runtime, or local files that are bundled at buildtime.

## How to use
### XML/MRSS format
For the content to be loaded correctly, the input must be in the allowed formats (see the `Test Content` folder for examples) 

It can either be an XML file with the following structure:
```
<feed>
    <entry>
        title>{Video title}</title>
        <id>{Unique video ID}</id>
        <link>{HLS manifest URL}</link>
        <image>{Thumbnail image URL}</image>
    </entry>
</feed>
```

Or an XML MRSS feed with the following structure:
```
<rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
   <channel>
      <item>
         <title>{Video title}</title>
         <guid isPermaLink="false">{Unique video ID}</guid>
         <media:content url="{HLS manfiest URL}">
            <media:thumbnail url="{Thumbnail image URL}" />
         </media:content>
      </item>
   </channel>
</rss>
```
The `image` and `media:thumbnail` elements are **optional**.

### Specifying XML files/MRSS feeds
Select which XML files to use by setting the values for keys `VOD_XML` and `LIVE_XML` in the `Config.xcconfig` configuration file. The XML files can be specified as either URI:s or filenames within the project. If the value for a key is left empty, no videos will be loaded for that carousel.

URI:s can be specified as either HTTP, HTTPS or FILE URL:s. Remember to **escape double slashes**, and **replace spaces with %20**. To use HTTP, add your domain to Exception Domains in your Info.plist.
- HTTPS example: `https:\/\/testcontent.mrss.eyevinn.technology/`
- FILE example: `file:\/\/\/Users/sebastianljungman/Dropbox/Mac/Downloads/testContent.xml`

When using a file URL, the content of the specified file will be copied at build time to the `vodContentCopy` and `liveContentCopy` XML files in the **root folder** of the project, which are then bundled with the application. If these files are missing in the project, they will be created in the root folder if specifying file URL:s, **but** you will need to drag them into the project navigator for Xcode to recognize them. These files **MUST exist in the project for file URL:s to be used**.

If using filenames within the project, use only the filenames. No .xml extension, and no relative paths. If the files exists anywhere in the project, they should be found with just the filenames.
Note that files need to be added to the Xcode project navigator - It is not enough to add them in the project folder.
- Project filename example: `vodTestContent`

### Running the app
Select a target device (either a paired Apple TV or a simulator), and build the project.  

## Authors

This open source project is maintained by Eyevinn Technology

## Contributors

- Sebastian Ljungman (sebastian.ljungman@eyevinn.se)

You are welcome to either contribute to this project or spin-off a fork of your own. This code is released under the Apache 2.0 license.

In addition to contributing code, you can help to triage issues. This can include reproducing bug reports, or asking for vital information such as version numbers or reproduction instructions.

## License (Apache-2.0)

```
Copyright 2022 Eyevinn Technology AB

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
## About Eyevinn Technology

Eyevinn Technology is an independent consultant firm specialized in video and streaming. Independent in the way that we are not commercially tied to any platform or technology vendor.

At Eyevinn, every software developer consultant has a dedicated budget reserved for open source development and contribution to the open source community. This give us room for innovation, team building and personal competence development. And also gives us as a company a way to contribute back to the open source community.

Want to know more about Eyevinn and how it is to work here? Contact us at work@eyevinn.se!
