import Score

struct ReadTime: Node {
    let minutes: Int

    var body: some Node {
        Text { "\(minutes) min read" }
            .font(.mono, size: 11, color: .muted)
    }
}
