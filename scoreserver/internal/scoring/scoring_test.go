package scoring

import (
	"bytes"
	"image"
	"image/color"
	"image/png"
	"os"
	"testing"
)


// fullMargin covers the entire 80×64 image — used for synthetic tests.
var fullMargin = image.Rect(0, 0, CanonicalWidth, CanonicalHeight)

// makeTestPNG encodes a synthetic NRGBA image as PNG bytes.
func makeTestPNG(img *image.NRGBA) []byte {
	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		panic(err)
	}
	return buf.Bytes()
}

// blankImage returns an 80×64 all-black NRGBA image.
func blankImage() *image.NRGBA {
	return image.NewNRGBA(image.Rect(0, 0, CanonicalWidth, CanonicalHeight))
}

// setPixel sets a pixel to white (non-black ink).
func setWhite(img *image.NRGBA, x, y int) {
	img.SetNRGBA(x, y, color.NRGBA{R: 255, G: 255, B: 255, A: 255})
}

// setBlack explicitly sets a pixel to black.
func setBlack(img *image.NRGBA, x, y int) {
	img.SetNRGBA(x, y, color.NRGBA{R: 0, G: 0, B: 0, A: 255})
}

// placeNOTGate plants a single NOT-South gate (pattern "0011") at center (cx, cy).
// Pattern "0011" means corners (-1,-1)=black, (+1,-1)=black, (-1,+1)=white, (+1,+1)=white.
//
// Gate layout (B=black, W=white):
//
//	B W B
//	W B W
//	W W W
func placeNOTGate(img *image.NRGBA, cx, cy int) {
	// Orthogonal neighbors: all white
	setWhite(img, cx-1, cy)
	setWhite(img, cx+1, cy)
	setWhite(img, cx, cy-1)
	setWhite(img, cx, cy+1)
	// Center: black (already black by default, but be explicit)
	setBlack(img, cx, cy)
	// NW corner: black
	setBlack(img, cx-1, cy-1)
	// NE corner: black
	setBlack(img, cx+1, cy-1)
	// SW corner: white
	setWhite(img, cx-1, cy+1)
	// SE corner: white
	setWhite(img, cx+1, cy+1)
}

// placeCrossing plants a crossing gate (pattern "0000") at center (cx, cy).
//
// Gate layout:
//
//	B W B
//	W B W
//	B W B
func placeCrossing(img *image.NRGBA, cx, cy int) {
	setWhite(img, cx-1, cy)
	setWhite(img, cx+1, cy)
	setWhite(img, cx, cy-1)
	setWhite(img, cx, cy+1)
	setBlack(img, cx, cy)
	setBlack(img, cx-1, cy-1)
	setBlack(img, cx+1, cy-1)
	setBlack(img, cx-1, cy+1)
	setBlack(img, cx+1, cy+1)
}

// --- DecodePNG tests ---

func TestDecodePNG_valid(t *testing.T) {
	img := blankImage()
	data := makeTestPNG(img)
	got, err := DecodePNG(data)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	b := got.Bounds()
	if b.Dx() != CanonicalWidth || b.Dy() != CanonicalHeight {
		t.Errorf("got size %dx%d, want %dx%d", b.Dx(), b.Dy(), CanonicalWidth, CanonicalHeight)
	}
}

func TestDecodePNG_wrongDimensions(t *testing.T) {
	small := image.NewNRGBA(image.Rect(0, 0, 10, 10))
	data := makeTestPNG(small)
	_, err := DecodePNG(data)
	if err == nil {
		t.Fatal("expected error for wrong dimensions, got nil")
	}
}

func TestDecodePNG_notPNG(t *testing.T) {
	_, err := DecodePNG([]byte("not a png"))
	if err == nil {
		t.Fatal("expected error for garbage input, got nil")
	}
}

// --- Metrics tests ---

func TestMetrics_allBlack(t *testing.T) {
	img := blankImage()
	m := ComputeMetrics(img, fullMargin)
	if m.TotalInk != 0 {
		t.Errorf("TotalInk: got %d, want 0", m.TotalInk)
	}
	if m.Gates != 0 {
		t.Errorf("Gates: got %d, want 0", m.Gates)
	}
	if m.CoreArea != 0 {
		t.Errorf("CoreArea: got %d, want 0", m.CoreArea)
	}
}

func TestMetrics_totalInkOnly(t *testing.T) {
	img := blankImage()
	// Set 5 scattered white pixels, none forming a gate.
	for _, p := range [][2]int{{0, 0}, {79, 63}, {40, 32}, {10, 10}, {70, 50}} {
		setWhite(img, p[0], p[1])
	}
	m := ComputeMetrics(img, fullMargin)
	if m.TotalInk != 5 {
		t.Errorf("TotalInk: got %d, want 5", m.TotalInk)
	}
	if m.Gates != 0 {
		t.Errorf("Gates: got %d, want 0", m.Gates)
	}
}

func TestMetrics_oneNOTGate(t *testing.T) {
	img := blankImage()
	// Place a NOT gate at an interior position well away from borders.
	cx, cy := 20, 20
	placeNOTGate(img, cx, cy)

	m := ComputeMetrics(img, fullMargin)
	if m.Gates != 1 {
		t.Errorf("Gates: got %d, want 1", m.Gates)
	}
	// Core area of a single gate: (max-min+1) * (max-min+1) = 1*1 = 1
	if m.CoreArea != 1 {
		t.Errorf("CoreArea: got %d, want 1", m.CoreArea)
	}
	// Ink pixels: center is black, 4 orthogonal are white, SW+SE corners are white = 6 white pixels.
	if m.TotalInk != 6 {
		t.Errorf("TotalInk: got %d, want 6", m.TotalInk)
	}
}

func TestMetrics_crossingNotCountedInGates(t *testing.T) {
	img := blankImage()
	cx, cy := 20, 20
	placeCrossing(img, cx, cy)

	m := ComputeMetrics(img, fullMargin)
	// Crossings do not count as gates.
	if m.Gates != 0 {
		t.Errorf("Gates: got %d, want 0 (crossings don't count)", m.Gates)
	}
	// But they do contribute to CoreArea.
	if m.CoreArea != 1 {
		t.Errorf("CoreArea: got %d, want 1", m.CoreArea)
	}
}

func TestMetrics_twoGatesSpacing(t *testing.T) {
	img := blankImage()
	// Place two NOT gates at (10,10) and (30,10).
	// The bounding box is 21 wide (30-10+1) and 1 tall → area = 21.
	placeNOTGate(img, 10, 10)
	placeNOTGate(img, 30, 10)

	m := ComputeMetrics(img, fullMargin)
	if m.Gates != 2 {
		t.Errorf("Gates: got %d, want 2", m.Gates)
	}
	if m.CoreArea != 21 {
		t.Errorf("CoreArea: got %d, want 21 (bounding box 21×1)", m.CoreArea)
	}
}

func TestMetrics_crossingInCoreArea(t *testing.T) {
	img := blankImage()
	// Crossing at (10,10), NOT gate at (30,30).
	// Bounding box: x from 10 to 30 = 21 wide, y from 10 to 30 = 21 tall → area = 441.
	placeCrossing(img, 10, 10)
	placeNOTGate(img, 30, 30)

	m := ComputeMetrics(img, fullMargin)
	if m.Gates != 1 {
		t.Errorf("Gates: got %d, want 1", m.Gates)
	}
	if m.CoreArea != 441 {
		t.Errorf("CoreArea: got %d, want 441", m.CoreArea)
	}
}

// --- ContentHash tests ---

func TestContentHash_identical(t *testing.T) {
	img1 := blankImage()
	img2 := blankImage()
	setWhite(img1, 5, 5)
	setWhite(img2, 5, 5)
	if ContentHash(img1) != ContentHash(img2) {
		t.Error("identical images produced different hashes")
	}
}

func TestContentHash_differs(t *testing.T) {
	img1 := blankImage()
	img2 := blankImage()
	setWhite(img1, 5, 5)
	setWhite(img2, 6, 6) // different pixel
	if ContentHash(img1) == ContentHash(img2) {
		t.Error("different images produced the same hash")
	}
}

func TestContentHash_alphaIgnored(t *testing.T) {
	img1 := blankImage()
	img2 := blankImage()
	// Same RGB, different alpha — Normalize forces alpha=255, so hashes must match.
	img1.SetNRGBA(5, 5, color.NRGBA{R: 200, G: 100, B: 50, A: 255})
	img2.SetNRGBA(5, 5, color.NRGBA{R: 200, G: 100, B: 50, A: 128})
	// ContentHash only looks at RGB, so these should be equal.
	if ContentHash(img1) != ContentHash(img2) {
		t.Error("images with same RGB but different alpha should hash identically")
	}
}

// --- Real circuit fixture ---

func TestMetrics_realCircuit7(t *testing.T) {
	data, err := os.ReadFile("testdata/circuit-7.png")
	if err != nil {
		t.Fatalf("read fixture: %v", err)
	}
	raw, err := DecodePNG(data)
	if err != nil {
		t.Fatalf("decode: %v", err)
	}
	img := Normalize(raw)

	// Puzzle 7 (7.latch): margin = Rect.Make(18, 0, 44, circuitPic.height)
	// Converted from MiniScript coords (y=0 at bottom) to PNG coords (y=0 at top):
	//   pngMinY = 64 - (0 + 64) = 0  →  image.Rect(18, 0, 62, 64)
	// Since the margin spans the full height the y-flip has no effect here.
	margin := image.Rect(18, 0, 62, 64)
	m := ComputeMetrics(img, margin)

	if m.Gates != 10 {
		t.Errorf("Gates: got %d, want 10", m.Gates)
	}
	if m.TotalInk != 433 {
		t.Errorf("TotalInk: got %d, want 433", m.TotalInk)
	}
	if m.CoreArea != 228 {
		t.Errorf("CoreArea: got %d, want 228 (margin may be wrong)", m.CoreArea)
	}
}

// --- Normalize tests ---

func TestNormalize_forcesAlpha(t *testing.T) {
	src := image.NewNRGBA(image.Rect(0, 0, CanonicalWidth, CanonicalHeight))
	src.SetNRGBA(0, 0, color.NRGBA{R: 255, G: 0, B: 0, A: 64})
	dst := Normalize(src)
	c := dst.NRGBAAt(0, 0)
	if c.A != 255 {
		t.Errorf("alpha after Normalize: got %d, want 255", c.A)
	}
}
