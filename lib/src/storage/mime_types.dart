/// Extension to MIME type table shared by the pickers and the `XFile`
/// conversion, so a file gets the same type whichever way it was picked.
library;

const Map<String, String> _mimeTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'bmp': 'image/bmp',
  'heic': 'image/heic',
  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'avi': 'video/x-msvideo',
  'mkv': 'video/x-matroska',
  'webm': 'video/webm',
  'pdf': 'application/pdf',
  'doc': 'application/msword',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'ppt': 'application/vnd.ms-powerpoint',
  'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'txt': 'text/plain',
  'json': 'application/json',
  'xml': 'application/xml',
  'zip': 'application/zip',
  'rar': 'application/vnd.rar',
};

/// The MIME type for [fileName], or null when its extension is missing or
/// unknown to the table.
String? mimeTypeForFileName(String fileName) {
  // A leading dot marks a hidden file, not an extension.
  final int dot = fileName.lastIndexOf('.');
  if (dot <= 0) return null;

  return _mimeTypes[fileName.substring(dot + 1).toLowerCase()];
}
