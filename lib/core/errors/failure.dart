/// A user-facing error, translated from whatever exception the data layer threw.
///
/// UI code should only ever render [message] — it never inspects raw
/// Firebase/platform exceptions, so a misconfigured backend (e.g. the
/// placeholder `firebase_options.dart`) surfaces a friendly state instead of
/// a crash.
class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}
