package scoring

import "image"

// Metrics holds the three scoring values computed from a circuit PNG.
type Metrics struct {
	Gates    int // count of NOT gates (crossings excluded)
	TotalInk int // count of non-black pixels
	CoreArea int // bounding-box area of all gates (NOT gates + crossings)
}

// ComputeMetrics computes all three metrics from a normalized image.
// Call Normalize before this function to ensure consistent pixel representation.
//
// margin is the player-editable rectangle; gates outside it are excluded from
// the coreArea bounding box (matching the MiniScript context.margin filter).
// Pass image.Rect(0, 0, 80, 64) to include all gates.
func ComputeMetrics(img *image.NRGBA, margin image.Rectangle) Metrics {
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()

	// Count non-black pixels across the full image.
	totalInk := 0
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if !isBlack(img, x, y) {
				totalInk++
			}
		}
	}

	// Find gates.
	gr := findGates(img)

	// Core area: bounding box of gate positions that fall within the margin,
	// +1 to each dimension.  Matches the MiniScript reference implementation:
	//   coreArea.width += 1; coreArea.height += 1
	coreArea := 0
	first := true
	var minX, maxX, minY, maxY int
	for _, p := range gr.allGatePositions {
		if !p.In(margin) {
			continue
		}
		if first {
			minX, maxX, minY, maxY = p.X, p.X, p.Y, p.Y
			first = false
		} else {
			if p.X < minX {
				minX = p.X
			}
			if p.X > maxX {
				maxX = p.X
			}
			if p.Y < minY {
				minY = p.Y
			}
			if p.Y > maxY {
				maxY = p.Y
			}
		}
	}
	if !first {
		coreArea = (maxX - minX + 1) * (maxY - minY + 1)
	}

	return Metrics{
		Gates:    gr.notGateCount,
		TotalInk: totalInk,
		CoreArea: coreArea,
	}
}
