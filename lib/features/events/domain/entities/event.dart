/// Clean-arch domain entity barrel for Events.
///
/// Re-exports the Event + EventCategory + TicketTier classes from the
/// pre-split models.dart. Keeping them physically in `core/models/`
/// avoids a sweeping import rewrite across the 100+ files that still
/// read them from there. When `core/models/models.dart` is finally
/// split per feature, these classes move here and the re-export is
/// deleted; call sites don't change.
library;

export '../../../../core/models/models.dart'
    show Event, EventCategory, TicketTier;
