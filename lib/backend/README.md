# Backend

Everything that talks to a server, an API, or a piece of persistent
infrastructure lives here. UI code should NEVER call an API directly. It
calls a service in this folder, which does the network work and returns a
typed Dart object.

## Layers

```
api/          — raw HTTP clients. One file per third-party service.
                Knows nothing about our domain models.
models/       — Dart shapes of API responses (`ApiHoroscopeResponse`, etc).
                Not the same as our UI models — these are strictly
                request/response.
services/     — domain-facing layer. UI imports THIS.
                Wraps api/, adds caching + fallbacks + error handling.
                Returns UI-ready domain objects.
```

## The rule

Every service **must** have a fallback path when the API is down or the
network is off. Hatri is a magazine you flip through. It should never
show "Error 500". It should show the last cached issue or a seeded default.

## Adding a new API

1. Add the raw HTTP client under `api/`.
2. Add response shapes under `models/`.
3. Add a domain service under `services/` that:
   - Calls the api layer
   - Caches (SharedPreferences or in-memory)
   - Falls back to seeded / cached data on failure
4. Wire the service in a widget via `FutureBuilder` or a `ChangeNotifier`.

## Auth, storage, notifications

When Firebase / Supabase / etc gets wired in, each one is its own folder
inside `services/` — e.g. `services/auth_service.dart`,
`services/storage_service.dart`, `services/notification_service.dart`.
