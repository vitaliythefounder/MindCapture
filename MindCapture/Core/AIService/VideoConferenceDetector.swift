//
//  VideoConferenceDetector.swift
//  MindCapture
//
//  Created by Claude on 10/23/25.
//

import Foundation

struct VideoConferenceInfo {
    let service: String
    let url: String
}

class VideoConferenceDetector {
    // Comprehensive pattern matching for 30+ video conference services
    static let patterns: [String: String] = [
        "Zoom": #"https?://(?:.*\.)?zoom\.(?:us|com|gov)/j/[\w\-?=&]+"#,
        "Google Meet": #"https?://meet\.google\.com/[\w\-]+"#,
        "Microsoft Teams": #"https?://teams\.microsoft\.com/[\w\-?=&/]+"#,
        "WebEx": #"https?://(?:.*\.)?webex\.com/[\w\-?=&/]+"#,
        "GoToMeeting": #"https?://(?:.*\.)?(?:gotomeet\.me|gotomeeting\.com)/[\w\-]+"#,
        "Whereby": #"https?://(?:.*\.)?whereby\.com/[\w\-]+"#,
        "Jitsi": #"https?://meet\.jit\.si/[\w\-]+"#,
        "BlueJeans": #"https?://(?:.*\.)?bluejeans\.com/[\w\-?=&/]+"#,
        "Skype": #"https?://join\.skype\.com/[\w\-]+"#,
        "Cisco": #"https?://(?:.*\.)?cisco\.com/[\w\-?=&/]+"#,
        "RingCentral": #"https?://(?:.*\.)?ringcentral\.com/[\w\-?=&/]+"#,
        "8x8": #"https?://(?:.*\.)?8x8\.vc/[\w\-]+"#,
        "Dialpad": #"https?://(?:.*\.)?dialpad\.com/[\w\-?=&/]+"#,
        "Around": #"https?://(?:.*\.)?around\.co/[\w\-]+"#,
        "Discord": #"https?://discord\.(?:gg|com/channels)/[\w\-/]+"#,
        "Slack Huddle": #"https?://(?:.*\.)?slack\.com/huddle/[\w\-/]+"#,
        "Amazon Chime": #"https?://chime\.aws/[\w\-]+"#,
        "Google Duo": #"https?://duo\.google\.com/[\w\-?=&/]+"#,
        "FaceTime": #"facetime://[\w\-?=&/]+"#,
        "Lifesize": #"https?://(?:.*\.)?lifesizecloud\.com/[\w\-?=&/]+"#,
        "Zoho Meeting": #"https?://(?:.*\.)?zoho\.com/meeting/[\w\-?=&/]+"#,
        "Join.me": #"https?://(?:.*\.)?join\.me/[\w\-]+"#,
        "ClickMeeting": #"https?://(?:.*\.)?clickmeeting\.com/[\w\-?=&/]+"#,
        "Demio": #"https?://(?:.*\.)?demio\.com/[\w\-?=&/]+"#,
        "BigMarker": #"https?://(?:.*\.)?bigmarker\.com/[\w\-?=&/]+"#,
        "Livestorm": #"https?://(?:.*\.)?livestorm\.co/[\w\-?=&/]+"#,
        "Vonage": #"https?://(?:.*\.)?vonage\.com/[\w\-?=&/]+"#,
        "Eyeson": #"https?://(?:.*\.)?eyeson\.com/[\w\-?=&/]+"#,
        "StarLeaf": #"https?://(?:.*\.)?starleaf\.com/[\w\-?=&/]+"#,
        "Highfive": #"https?://(?:.*\.)?highfive\.com/[\w\-?=&/]+"#,
        "UberConference": #"https?://(?:.*\.)?uberconference\.com/[\w\-]+"#,
        "Meet.coop": #"https?://meet\.coop/[\w\-]+"#,
        "Jami": #"https?://jami\.net/[\w\-?=&/]+"#
    ]

    /// Detects video conference links in text
    /// - Parameter text: The text to scan for video conference links
    /// - Returns: VideoConferenceInfo if a link is found, nil otherwise
    static func detect(in text: String) -> VideoConferenceInfo? {
        for (service, pattern) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
                continue
            }

            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, range: range) {
                guard let urlRange = Range(match.range, in: text) else { continue }
                let url = String(text[urlRange])
                return VideoConferenceInfo(service: service, url: url)
            }
        }
        return nil
    }

    /// Detects all video conference links in text
    /// - Parameter text: The text to scan for video conference links
    /// - Returns: Array of VideoConferenceInfo for all detected links
    static func detectAll(in text: String) -> [VideoConferenceInfo] {
        var results: [VideoConferenceInfo] = []

        for (service, pattern) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
                continue
            }

            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, range: range)

            for match in matches {
                guard let urlRange = Range(match.range, in: text) else { continue }
                let url = String(text[urlRange])
                results.append(VideoConferenceInfo(service: service, url: url))
            }
        }

        return results
    }

    /// Returns the appropriate SF Symbol icon for the service
    static func icon(for service: String) -> String {
        switch service.lowercased() {
        case "zoom", "google meet", "microsoft teams", "webex", "skype":
            return "video.fill"
        case "discord", "slack huddle":
            return "message.fill"
        default:
            return "video.circle.fill"
        }
    }
}
