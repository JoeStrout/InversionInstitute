package scoring

import (
	"crypto/sha256"
	"encoding/hex"
	"image"
)

// ContentHash returns a hex-encoded SHA-256 hash of the canonical pixel data.
// Only RGB bytes are hashed (in row-major order); alpha is excluded because
// Normalize forces it to 255 for all pixels.
func ContentHash(img *image.NRGBA) string {
	b := img.Bounds()
	h := sha256.New()
	row := make([]byte, 3*b.Dx())
	for y := b.Min.Y; y < b.Max.Y; y++ {
		i := 0
		for x := b.Min.X; x < b.Max.X; x++ {
			c := img.NRGBAAt(x, y)
			row[i] = c.R
			row[i+1] = c.G
			row[i+2] = c.B
			i += 3
		}
		h.Write(row)
	}
	return hex.EncodeToString(h.Sum(nil))
}
