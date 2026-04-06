import 'package:image/image.dart' as img;

/// Extract R,G,B from pixel value
num r(img.Color c) => c.r;
num g(img.Color c) => c.g;
num b(img.Color c) => c.b;

/// ---------------------------
/// 1) Adjust Contrast
/// ---------------------------
img.Image adjustContrast(img.Image src, double contrast) {
  final factor = (259 * (contrast + 1)) / (255 * (1 - contrast));

  final out = img.Image.from(src);

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);

      int nr = (factor * (r(p) - 128) + 128).clamp(0, 255).toInt();
      int ng = (factor * (g(p) - 128) + 128).clamp(0, 255).toInt();
      int nb = (factor * (b(p) - 128) + 128).clamp(0, 255).toInt();

      out.setPixelRgba(x, y, nr, ng, nb, 255);
    }
  }

  return out;
}

/// ---------------------------
/// 2) Floyd–Steinberg Dithering
/// ---------------------------
img.Image floydSteinberg(img.Image src) {
  final w = src.width;
  final h = src.height;

  final out = img.Image.from(src);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final oldPixel = r(out.getPixel(x, y));
      final newPixel = oldPixel < 128 ? 0 : 255;
      final error = oldPixel - newPixel;

      out.setPixelRgba(x, y, newPixel, newPixel, newPixel, 255);

      void spread(int dx, int dy, double factor) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) return;

        final p = out.getPixel(nx, ny);
        int newVal = (r(p) + error * factor).clamp(0, 255).toInt();
        out.setPixelRgba(nx, ny, newVal, newVal, newVal, 255);
      }

      spread(1, 0, 7 / 16);
      spread(-1, 1, 3 / 16);
      spread(0, 1, 5 / 16);
      spread(1, 1, 1 / 16);
    }
  }

  return out;
}
