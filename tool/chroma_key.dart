import 'dart:io';
import 'package:image/image.dart';

void main() {
  final outDir = Directory('assets/images');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  // New Magenta eggs + Old Green pot
  final Map<String, String> files = {
    'pot_front': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\pot_front_1773157508156.png',
    'egg_chilling': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\egg_chilling_1773158437746.png',
    'egg_warming': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\egg_warming_1773158466077.png',
    'egg_boiling': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\egg_boiling_1773158488469.png',
    'egg_panic': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\egg_panic_1773158505888.png',
    'egg_celebrate': r'C:\Users\Ashiqe\.gemini\antigravity\brain\bf9be20b-7d7d-481a-854b-a09ca471e37b\egg_celebrate_1773158524617.png',
  };

  for (final entry in files.entries) {
    print('Processing ${entry.key}...');
    final file = File(entry.value);
    final image = decodeImage(file.readAsBytesSync());
    if (image == null) continue;

    if (!image.hasAlpha) {
       final converted = Image(width: image.width, height: image.height, numChannels: 4);
       for (final p in image) {
          converted.setPixel(p.x, p.y, ColorRgba8(p.r.toInt(), p.g.toInt(), p.b.toInt(), 255));
       }
       for (final p in converted) {
         image.setPixel(p.x, p.y, p);
       }
    }

    // Determine background color based on the corners (assuming it's a solid block)
    final bg = image.getPixel(0, 0);
    final isMagentaBg = bg.r > 200 && bg.b > 200 && bg.g < 100;
    final isGreenBg = bg.g > 200 && bg.r < 100 && bg.b < 100;

    for (final p in image) {
      final r = p.r;
      final g = p.g;
      final b = p.b;

      if (isMagentaBg) {
        // Detect pure magenta (#FF00FF usually r>200, b>200, g<50)
        if (r > 150 && b > 150 && g < r * 0.5 && g < b * 0.5) {
          p.a = 0;
        } else if (r > 100 && b > 100 && g < r * 0.8 && g < b * 0.8) {
          // Anti-alias edge
          p.a = (p.a / 2).round();
          // Desaturate the magenta fringe slightly
          p.r = (r * 0.5).round();
          p.b = (b * 0.5).round();
        }
      } else if (isGreenBg) {
        // Detect neon green
        if (g > 150 && g > r * 1.5 && g > b * 1.5) {
          p.a = 0;
        } else if (g > 100 && g > r * 1.2 && g > b * 1.2) {
          p.a = (p.a / 2).round();
        }
      } else {
        // If the AI completely ignored our background request and drew a real scene (like a floor),
        // we'll just try to kill anything that looks like "white/grey background" if possible,
        // but hopefully the strict sticker prompt worked and it's magenta!
        
        // Also kill pure white backgrounds if they snuck in
        if (r > 240 && g > 240 && b > 240) {
          p.a = 0;
        }
      }
    }

    final outFile = File('assets/images/${entry.key}.png');
    outFile.writeAsBytesSync(encodePng(image));
    print('Saved ${entry.key}.png');
  }
}
