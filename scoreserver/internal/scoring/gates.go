package scoring

import "image"

// gateResult holds the output of findGates.
type gateResult struct {
	notGateCount     int          // count of NOT gates (crossings excluded)
	allGatePositions []image.Point // all gate positions: NOT gates + crossings
}

// isBlack returns true if the pixel at (x,y) has R=G=B=0.
// After Normalize, alpha is always 255, so we only check RGB.
func isBlack(img *image.NRGBA, x, y int) bool {
	c := img.NRGBAAt(x, y)
	return c.R == 0 && c.G == 0 && c.B == 0
}

// findGates scans the image for gate patterns, porting the findGates function
// from rlms/assets/pixelLogicSim.ms.
//
// A gate candidate is any interior pixel where:
//   - the center is black
//   - all four orthogonal neighbors (N, S, E, W) are non-black
//
// The four corner positions are then checked.  A corner counts as "0" if it
// is black or a previously-found crossing position; otherwise "1".
// The resulting 4-bit pattern (corners in order NW, NE, SW, SE in PNG coords,
// which matches the MiniScript scan order) determines the gate type:
//
//	"0000" → crossing (not counted in notGateCount; tracked for later corners)
//	"1010" → NOT gate (East)
//	"1100" → NOT gate (North, in MiniScript coords)
//	"0101" → NOT gate (West)
//	"0011" → NOT gate (South, in MiniScript coords)
//
// Because we only need counts and bounding-box area (not directional info),
// the y-axis difference between MiniScript display coords and PNG coords does
// not affect any computed metric.
func findGates(img *image.NRGBA) gateResult {
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()

	crossings := make(map[image.Point]bool)
	var allPositions []image.Point
	notCount := 0

	// Scan interior pixels only (skip the 1-pixel border).
	for y := 1; y < h-1; y++ {
		for x := 1; x < w-1; x++ {
			// Center must be black.
			if !isBlack(img, x, y) {
				continue
			}
			// All four orthogonal neighbors must be non-black.
			if isBlack(img, x-1, y) || isBlack(img, x+1, y) ||
				isBlack(img, x, y-1) || isBlack(img, x, y+1) {
				continue
			}

			// Check corners: (-1,-1), (+1,-1), (-1,+1), (+1,+1).
			// A corner is "0" if it is black or a known crossing.
			var pat [4]byte
			corners := [4]image.Point{
				{x - 1, y - 1},
				{x + 1, y - 1},
				{x - 1, y + 1},
				{x + 1, y + 1},
			}
			for i, c := range corners {
				if isBlack(img, c.X, c.Y) || crossings[c] {
					pat[i] = '0'
				} else {
					pat[i] = '1'
				}
			}
			p := string(pat[:])

			switch p {
			case "0000": // crossing
				crossings[image.Point{x, y}] = true
				allPositions = append(allPositions, image.Point{x, y})
			case "1010", "1100", "0101", "0011": // NOT gate (any orientation)
				notCount++
				allPositions = append(allPositions, image.Point{x, y})
			}
		}
	}

	return gateResult{notGateCount: notCount, allGatePositions: allPositions}
}
