import Foundation
import Score

struct FeedController: Controller {
    var base: String { "/" }

    var routes: [Route] {
        [
            Route(method: .get, path: "feed.xml", handler: rssFeed),
        ]
    }

    func rssFeed(_ ctx: RequestContext) async throws -> Response {
        let store = try LibrettoStore.persistent()
        let posts = try await store.listPublishedPosts(limit: 20)

        let rfc822Formatter: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            f.timeZone = TimeZone(identifier: "UTC")
            return f
        }()

        var items = ""
        for post in posts {
            let title = xmlEscape(post.title)
            let link = "https://libretto.allegro.dev/@\(post.authorId)/\(post.slug)"
            let raw = post.excerpt ?? String(post.body.prefix(300))
            let description = xmlEscape(raw.trimmingCharacters(in: .whitespacesAndNewlines))
            let pubDate = post.publishedAt.map { rfc822Formatter.string(from: $0) } ?? ""

            items += """
                <item>
                  <title>\(title)</title>
                  <link>\(link)</link>
                  <description>\(description)</description>
                  <pubDate>\(pubDate)</pubDate>
                  <guid>\(link)</guid>
                </item>

            """
        }

        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Libretto</title>
                <link>https://libretto.allegro.dev</link>
                <description>Writing and publishing platform</description>
                <language>en-us</language>
            \(items)  </channel>
            </rss>
            """

        return Response(
            status: .ok,
            headers: ["content-type": "application/rss+xml; charset=utf-8"],
            body: Data(xml.utf8)
        )
    }

    private func xmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
