abstract class RowReader {
  Future<List<String>> readHeaders(String path);
  Future<List<Map<String, String>>> readRows(String path);
}
