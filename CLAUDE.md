# Libretto

Blogging and writing platform — a Score web app serving as the public reference application for the Score framework.

## Architecture

- **Pages** — LandingPage, BlogListPage, PostPage, ProfilePage, SettingsPage, EditorPage, DraftsPage, BillingPage, CheckoutPage, LoginPage, LibrettoErrorPage
- **Components** — NavBar, LibrettoSidebarLayout, TopicPill, ToolbarButton, PlanComparisonRow
- **Helpers** — AuthHelper, ClientScripts (shared JS for SCORE-GAP workarounds), LibrettoStore
- **Controllers** — AuthController, PostController, PublicPostController, ProfileController, BillingController, FeedController, LikeController, CommentController
- **Models** — Post, User, Comment, Like, Plan
- **Dependencies** — Score framework, allegro-theme, score-oauth, score-payments, score-lucide

## Score Rules

This is a Score app. All code must follow Score conventions:

- **Never use inline JS or CSS** — no `htmlAttribute("style", ...)`, no `htmlAttribute("onclick", ...)`, no `RawTextNode("<style>...")`.
- **Use Score modifiers** for all styling (`.flex()`, `.font()`, `.background()`, etc.)
- **Use `@State`/`@Action`** for interactivity.
- **`RawTextNode("<script>...")`** is only acceptable when marked with `// SCORE-GAP:` for features the framework doesn't support yet (client-side fetch, timers, polling).
- **Components** must be `UpperCamelCase` `@Component struct` definitions.

## allegro-theme Components

Shared UI from the `allegro-theme` plugin is available:
- Layout: `AppHeader`, `AppFooter`, `AppLayout`, `AppSidebar`, `SidebarLayout`
- Navigation: `NavLink`, `ThemeToggle`, `LanguageDropdown`
- Buttons: `SubmitButton`, `SecondaryButton`, `ActionLink`, `BackLink`
- Forms: `FormField`, `UsageBar`
- Primitives: `Badge`, `StatusDot`, `Divider`, `SectionLabel`
- Auth: `AuthLoginPage`
- Errors: `ThemeErrorPage`

## Localization

This app uses Score's i18n system:

- **String catalog:** `Localizable.xcstrings` — Xcode String Catalog format (JSON). Source language is `en`.
- **Loading:** `App.swift` loads the catalog via `Localization(catalog: StringCatalog.load(from: "Localizable.xcstrings"))`.
- **Usage in components:** Use `t("key")` in node builder bodies and as component props.
- **Routing:** Default locale (`en`) renders at `/`, others render at `/<locale>/` (e.g. `/es/blog`).
- **Language switcher:** `LanguageDropdown` from allegro-theme in the NavBar — reads supported locales from the string catalog automatically.
- **Adding a language:** Add translations to `Localizable.xcstrings` under a new locale key. The dropdown and routing pick it up automatically.
- **Adding a string:** Add the key to `Localizable.xcstrings` with translations for all supported locales, then use `t("key")` in your component.

## Development

```bash
swift run score dev  # Dev server with hot reload
swift run score build  # Production build
```

## Tooling

- Swift 6.3, `swift format` with shared `.swift-format` config
- `hk.pkl` pre-commit hooks: format, build
- `mise.toml` for task definitions
- Commit messages: `feat:`, `fix:`, `refactor:`, `chore:`, `test:`
