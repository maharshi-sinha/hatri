/// Marquee domain entity barrel. The DTO is reused as the entity for now;
/// a later PR introduces a plain MarqueeItem class and ApiMarqueeItem
/// becomes a data-layer DTO with a mapper.
library;

export '../../../../backend/models/marquee_models.dart' show ApiMarqueeItem;
