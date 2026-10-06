/// The band at the foot of every screen that the page indicator occupies,
/// measured above the system safe area.
///
/// Shared because two places need the same number and they must not disagree:
/// the router draws a scrim this tall so scrolled content fades out behind the
/// labels, and anything that has to stay usable at the bottom of a screen —
/// the add button on the log screen — lifts clear of it. When they disagreed,
/// the scrim swallowed the add button (#201).
const kNavBandHeight = 64.0;
