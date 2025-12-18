String resolveImageUrl(String raw) {
  if (raw.isEmpty) return '';

  if (raw.startsWith('http')) {
    return raw; // placeholder veya direkt url
  }

  return 'https://dailygood.dijicrea.net/storage/$raw';
}
