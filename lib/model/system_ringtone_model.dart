/// 系统铃声
class SystemRingtoneModel {
  const SystemRingtoneModel(
      {required this.ringtoneTitle, required this.ringtoneUri});

  final String ringtoneTitle;
  final String ringtoneUri;

  factory SystemRingtoneModel.fromJson(Map<String, dynamic> json) {
    return SystemRingtoneModel(
        ringtoneTitle: json["ringtoneTitle"] ?? "",
        ringtoneUri: json["ringtoneUri"] ?? "");
  }

  static List<SystemRingtoneModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((e) => SystemRingtoneModel.fromJson(e)).toList();
  }
}
