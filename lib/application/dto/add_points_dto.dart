final class AddPointsDto {
  const AddPointsDto({
    required this.userId,
    required this.dateTime,
    required this.points,
    required this.reason,
    this.tag,
  });
  final int userId;
  final DateTime dateTime;
  final int points;
  final String reason;
  final String? tag;
}
