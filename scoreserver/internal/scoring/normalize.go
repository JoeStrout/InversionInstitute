package scoring

import (
	"bytes"
	"image"
	"image/color"
	"image/png"
)

// Normalize converts any image.Image to a canonical *image.NRGBA with
// alpha forced to 255 for every pixel.  Two PNG files encoding the same
// pixels but with different alpha metadata will produce identical output.
func Normalize(src image.Image) *image.NRGBA {
	b := src.Bounds()
	w, h := b.Dx(), b.Dy()
	dst := image.NewNRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			r32, g32, b32, _ := src.At(b.Min.X+x, b.Min.Y+y).RGBA()
			dst.SetNRGBA(x, y, color.NRGBA{
				R: uint8(r32 >> 8),
				G: uint8(g32 >> 8),
				B: uint8(b32 >> 8),
				A: 255,
			})
		}
	}
	return dst
}

// EncodePNG re-encodes a normalized image to PNG bytes for canonical storage.
func EncodePNG(img *image.NRGBA) ([]byte, error) {
	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
