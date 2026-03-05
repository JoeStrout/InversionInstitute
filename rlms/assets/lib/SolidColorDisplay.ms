SolidColorDisplay = new Display
SolidColorDisplay.mode = displayMode.solidColor
SolidColorDisplay.color = [0, 0, 0, 255]

SolidColorDisplay.render = function
	raylib.DrawRectangle 0, 0, 960, 640, self.color
end function

return SolidColorDisplay
