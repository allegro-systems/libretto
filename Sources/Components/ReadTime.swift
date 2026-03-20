import Score

struct ReadTime: Node {
    let minutes: Int

    var body: some Node {
        Text { "\(minutes) min read" }
            .font(.sans, size: 12, color: .muted)
    }
}
