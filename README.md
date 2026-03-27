# Libretto

Blogging and writing platform — a Score web app serving as the public reference application for the Score framework.

## Secrets

Secrets are managed with [fnox](https://fnox.jdx.dev/) using [Infisical](https://infisical.com) (EU region). Each developer authenticates via a Machine Identity — no shared keys.

### First-time setup

1. Get a **Client ID** and **Client Secret** from your Infisical org admin (or create a Machine Identity with Universal Auth in the [Infisical dashboard](https://eu.infisical.com))
2. Ensure the identity is added to the Allegro project with read access
3. Store your credentials in the macOS Keychain:

```bash
security add-generic-password -a "infisical-client-id" -s "fnox" -w "<your-client-id>" -U
security add-generic-password -a "infisical-client-secret" -s "fnox" -w "<your-client-secret>" -U
```

4. Verify:

```bash
mise install
fnox get GITHUB_CLIENT_ID
```

Secrets are defined in `fnox.toml` and loaded automatically into the environment via mise.

## Development

```bash
swift run score dev   # Dev server with hot reload
swift run score build # Production build
```

All tasks are managed via `mise` and can be analyzed by running `mise run {task} --help` to see the task's description and options.
