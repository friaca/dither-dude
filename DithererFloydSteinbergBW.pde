import processing.core.PApplet; 
import processing.core.PImage;

/**
 * Implements Floyd-Steinberg dithering to convert an image to black and white.
 * Declared as a static nested class to allow static methods within a .pde file.
 * Requires passing the PApplet instance (the sketch) to access Processing functions.
 * Includes an option for serpentine (zigzag) scanning.
 */
public static class DithererFloydSteinbergBW { 

  // Private constructor to prevent instantiation
  private DithererFloydSteinbergBW() {}

  /**
   * Applies Floyd-Steinberg dithering to convert the input image to black and white.
   *
   * @param papplet The PApplet instance (usually 'this' from the calling sketch). 
   * Needed to access Processing functions like brightness() and color().
   * @param inputImage The PImage to dither.
   * @param useSerpentine If true, processes rows in alternating directions (zigzag). 
   * If false, processes all rows left-to-right.
   * @return A new PImage containing the black and white dithered result.
   * Returns null if inputImage or papplet is null.
   */
  public static PImage dither(PApplet papplet, PImage inputImage, boolean useSerpentine) { 
    if (inputImage == null) {
        PApplet.println("Error: Input image to dither is null."); 
        return null;
    }
     if (papplet == null) {
        PApplet.println("Error: PApplet instance (sketch) is null.");
        return null;
    }

    PImage img = inputImage.copy(); 
    int w = img.width;
    int h = img.height;

    img.loadPixels();
    float[][] grayBuffer = new float[h][w];

    // Initialize buffer with brightness values
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int index = y * w + x;
        grayBuffer[y][x] = papplet.brightness(img.pixels[index]); 
      }
    }

    // --- Main Dithering Loop ---
    for (int y = 0; y < h; y++) {

      // Determine scan direction for this row based on serpentine mode and row index
      boolean goingRight = !useSerpentine || (y % 2 == 0); // Go right if not serpentine or on even rows

      if (goingRight) {
        // === Scan Left-to-Right ===
        for (int x = 0; x < w; x++) {
          processPixel(papplet, img, grayBuffer, x, y, w, h, goingRight);
        }
      } else {
        // === Scan Right-to-Left ===
        for (int x = w - 1; x >= 0; x--) { // Iterate backwards
          processPixel(papplet, img, grayBuffer, x, y, w, h, goingRight);
        }
      }
    } // end y loop

    img.updatePixels();
    return img; 
  }

  /**
   * Helper method to process a single pixel: quantize and distribute error.
   * Handles different error distribution based on scan direction.
   */
  private static void processPixel(PApplet papplet, PImage img, float[][] grayBuffer, int x, int y, int w, int h, boolean goingRight) {
      
      // 1. Get current pixel's value (original + accumulated error)
      float oldGray = grayBuffer[y][x];
      
      // 2. Quantize to black (0) or white (255)
      float newGray = (oldGray < 200) ? 0.0f : 255.0f; 
      
      // 3. Set the corresponding pixel in the output image
      int index = y * w + x;
      img.pixels[index] = papplet.color(newGray); 

      // 4. Calculate the quantization error
      float quantError = oldGray - newGray;

      // 5. Distribute the error to neighbors *in the buffer*
      //    The distribution pattern depends on the scanning direction.
      if (goingRight) {
        // === Distribute error when scanning Left-to-Right ===
        // Pixel to the right -> (x+1, y) gets 7/16
        if (x + 1 < w) { 
          grayBuffer[y][x + 1] += quantError * 7.0f / 16.0f; 
        }
        // Pixel below-left -> (x-1, y+1) gets 3/16
        if (x - 1 >= 0 && y + 1 < h) { 
          grayBuffer[y + 1][x - 1] += quantError * 3.0f / 16.0f; 
        }
        // Pixel directly below -> (x, y+1) gets 5/16
        if (y + 1 < h) { 
          grayBuffer[y + 1][x] += quantError * 5.0f / 16.0f; 
        }
        // Pixel below-right -> (x+1, y+1) gets 1/16
        if (x + 1 < w && y + 1 < h) { 
          grayBuffer[y + 1][x + 1] += quantError * 1.0f / 16.0f; 
        }
      } else {
        // === Distribute error when scanning Right-to-Left ===
        // Error is distributed to pixels relative to current position,
        // but considering the leftward scan direction.
        // Pixel to the left -> (x-1, y) gets 7/16
        if (x - 1 >= 0) { 
          grayBuffer[y][x - 1] += quantError * 7.0f / 16.0f; 
        }
        // Pixel below-right -> (x+1, y+1) gets 3/16 
        if (x + 1 < w && y + 1 < h) { 
          grayBuffer[y + 1][x + 1] += quantError * 3.0f / 16.0f; 
        }
        // Pixel directly below -> (x, y+1) gets 5/16
        if (y + 1 < h) { 
          grayBuffer[y + 1][x] += quantError * 5.0f / 16.0f; 
        }
        // Pixel below-left -> (x-1, y+1) gets 1/16
        if (x - 1 >= 0 && y + 1 < h) { 
          grayBuffer[y + 1][x - 1] += quantError * 1.0f / 16.0f; 
        }
      }
  } // end processPixel
} // end class
