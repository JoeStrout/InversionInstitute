package scoring

import (
	"bytes"
	"fmt"
	"image"
	"image/png"
)

const (
	CanonicalWidth  = 80
	CanonicalHeight = 64
)

// DecodePNG decodes raw PNG bytes and verifies the image is exactly 80×64.
func DecodePNG(data []byte) (image.Image, error) {
	img, err := png.Decode(bytes.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("invalid PNG: %w", err)
	}
	b := img.Bounds()
	if b.Dx() != CanonicalWidth || b.Dy() != CanonicalHeight {
		return nil, fmt.Errorf("wrong dimensions: got %dx%d, want %dx%d",
			b.Dx(), b.Dy(), CanonicalWidth, CanonicalHeight)
	}
	return img, nil
}
