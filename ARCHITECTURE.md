# Hatri app architecture

This document describes the final state of the clean-architecture
migration shipped across arch/01 through arch/15 branches.

## Layer map

Each feature follows the same three-layer shape. Dependencies flow
inward only: presentation depends on domain, data depends on domain,
domain depends on nothing.

```
lib/
  main.dart
  app.dart (not yet extracted; still inside main.dart)
  core/
    constants/
    error/
      failures.dart        sealed Failure (Network, Server, NotFound,
                           Auth, Validation, Cache, Unknown)
      exceptions.dart      typed data-layer exceptions
    network/
      dio_client.dart      Dio factory with 4 interceptors
      network_info.dart    connectivity_plus wrapper
      interceptors/
        auth_interceptor.dart
        logging_interceptor.dart
        error_interceptor.dart
    usecases/
      usecase.dart         base UseCase<Return, Params>
      no_params.dart
    utils/
      either_x.dart        fpdart Either/Option barrel
    di/
      injection_container.dart   root DI, calls per-feature modules
    routing/ theme/ analytics/ geo/ notifications/ deeplinks/
    (cross-cutting)

  features/
    <feature>/
      data/
        datasources/       abstract + impl, throws typed exceptions
        repositories/      impl of domain repo, catches ->
                           maps to Failure
      domain/
        repositories/      abstract contract, returns Either<Failure,T>
        usecases/          one class per verb
      presentation/
        bloc/              (where blocs exist: events, communities)
        pages/             screens
        widgets/           (where feature-local widgets exist)
      di.dart              registerXFeature(sl) called from root DI

  shared/
    widgets/               shared UI + barrel (widgets.dart)
    design/                tokens, components

test/
  core/
  features/<feature>/
```

## Features that completed clean-arch

| Feature | data | domain | di | presentation move |
|---|---|---|---|---|
| events | yes | yes (10 use cases) | yes | yes |
| auth | yes | yes (5 use cases) | yes | yes (13 screens) |
| tickets | yes | yes (4 use cases) | yes | yes |
| makers | yes | yes (4 use cases) | yes | yes |
| profile | yes | yes (4 use cases) | yes | yes (6 screens) |
| communities | yes (local only) | yes (1 use case) | yes | yes |
| creators | yes (local only) | yes (2 use cases) | yes | yes |
| home | - | - | - | yes |
| discovery | - | - | - | yes |
| city | - | - | - | yes |
| saved | - | - | - | yes |
| plans | - | - | - | yes |
| support | - | - | - | yes |

Home / discovery / city / saved / plans / support are display-only.
They consume other features' repositories and have no data of their
own, so no new data/domain was created.

## Blocs on the clean-arch path

| Bloc | Status |
|---|---|
| EventsBloc | migrated. Uses GetEvents use case + bloc_concurrency transformers (restartable + droppable) |
| CommunitiesBloc | migrated. Uses GetCommunities use case + restartable() |

Every other screen in the app still uses `setState` with
`sl<XService>()` or `sl<XRepository>()` calls directly. The
clean-arch repositories + use cases are registered and ready; the
screen rewrites are deferred to a future behavior-touching sprint.
Rough budget: 40 to 60 hours. One Cubit per setState screen.

## Legacy layer still present

`lib/backend/` and `lib/core/repositories/` are intentionally kept
alive because the setState screens listed above still read them. The
new data layer wraps the services inside; the services wrap the APIs.
Order of removal when the setState screens migrate:

1. Rewrite each setState screen to drive a Cubit/Bloc that calls use
   cases.
2. Once no screen reads `sl<XService>()` directly, inline the
   service logic into the new RemoteDataSource and delete the
   service.
3. Once no feature imports `backend/api/api_exception.dart`, migrate
   `ErrorInterceptor` into the primary request path and delete the
   old `HttpClient.translate` method.
4. Delete `core/repositories/{event_repository, backend_event_repository,
   community_repository, creator_repository, mock_repository}.dart`.
5. Rename `lib/backend/` to `lib/legacy/` if any lonely files remain
   until the final sweep.

## Failure flow

```
remote throws DioException
   |
   V
ErrorInterceptor translates to typed exceptions in core/error/exceptions
   |
   V (crosses the data boundary)
Repository impl catches, maps to sealed Failure in core/error/failures
   |
   V
UseCase returns Either<Failure, T>
   |
   V
Bloc folds; UI gets a value or a typed Failure, never a raw exception
```

Call sites not yet on this path still throw `ApiException` from
`backend/api/api_exception.dart`. Both exception hierarchies are
live in parallel.

## DI composition

`core/di/injection_container.dart` registers legacy singletons first
(http_client, every *_api, every *_service, legacy repositories,
blocs), then calls each feature's `registerXFeature(sl)` which
adds the clean-arch bindings. Lazy singletons mean the registration
order between a bloc factory and the use case it will later resolve
does not matter.

Feature modules registered today, in call order:

- registerEventsFeature
- registerAuthFeature
- registerTicketsFeature
- registerMakersFeature
- registerProfileFeature
- registerCommunitiesFeature
- registerCreatorsFeature

## Testing

Three example suites locked in on arch/14:

- `test/core/error/failures_test.dart`
- `test/features/events/data/event_repository_impl_test.dart`
- `test/features/events/domain/get_events_test.dart`

Covers: Failure hierarchy equality, repo-level exception translation,
use-case parameter forwarding. mocktail for mocks. `bloc_test` is
intentionally not included (its current line pulls a matcher version
that collides with flutter_test's). Bloc tests can be written against
the plain Stream when needed.

## Entity barrels

Every feature has `features/<feature>/domain/entities/` with barrels
that re-export the current physical classes from `core/models/` and
`backend/models/`. Call sites can import from the clean-arch path
today; when `core/models/models.dart` is finally split per feature,
the classes move INTO the barrel files and the re-exports become
unnecessary, with no change at the call sites.

## What is not done

- bloc_test (matcher conflict in the current line).
- `app/` top folder with HatriApp extracted from main.dart. The file
  is still short enough to live under lib/main.dart; the extraction
  is cosmetic and will land when main.dart grows.
- Physical split of `core/models/models.dart` and
  `core/repositories/event_feed_page.dart`. The classes stay there
  until a dedicated split-models PR takes the ~100 call sites with
  it in one atomic rewrite. Barrels in each feature's domain/entities/
  insulate consumers.
- Freezed codegen is wired in pubspec but no file uses it yet. First
  consumer should run `dart run build_runner build --delete-conflicting-outputs`.
- ~40 setState screens still read `sl<XService>()` directly. The
  clean-arch repositories + use cases are registered and ready; each
  screen's rewrite into a Cubit + BlocBuilder is behavior-touching
  work. Rough budget 40 to 60 hours. The pattern is already proven
  on EventsBloc and CommunitiesBloc.
- Deletion of `lib/backend/` and `lib/core/repositories/`. Needs the
  setState screens migrated first, then service inlining into
  datasources, then the delete sweep. See the ordered deletion plan
  above.

## Branches shipped

```
arch/01-core-scaffold          core/error, core/network, core/usecases,
                               core/utils; package additions
arch/02-events-data-domain     events data+domain layer
arch/03-events-bloc-swap       EventsBloc uses GetEvents
arch/04-events-presentation    events screens -> presentation/pages
arch/05-auth-clean-arch        auth
arch/06-tickets-clean-arch     tickets
arch/07-makers-clean-arch      makers
arch/08-profile-clean-arch     profile
arch/09-communities-clean-arch communities + bloc move
arch/10-creators-clean-arch    creators
arch/11-small-batch-1          home, discovery, city presentation
arch/12-small-batch-2          saved, plans, support presentation
arch/13-bloc-polish            bloc_concurrency + CommunitiesBloc
                               clean-arch migration
arch/14-test-scaffolding       test tree + 3 example suites
arch/15-architecture-doc       this file (initial)
arch/16-entities-and-cubits    domain entity barrels per feature +
                               doc update
```
