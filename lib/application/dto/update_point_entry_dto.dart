final class UpdatePointEntryDto {
  const UpdatePointEntryDto({
    required this.id,
    required this.dateTime,
    required this.points,
    this.reason,
    this.application,
    this.tag,
  });
  final int id;
  final DateTime dateTime;
  final int points;
  final String? reason;
  final String? application;
  final String? tag;
}
