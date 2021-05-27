package main

import (
	"image/color"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/theme"
)

type myTheme struct{}

var _ fyne.Theme = (*myTheme)(nil)

func (m myTheme) Color(name fyne.ThemeColorName, variant fyne.ThemeVariant) color.Color {
	if name == theme.ColorNamePrimary {
		return color.RGBA{130, 195, 65, 100}
	}
	if name == theme.ColorNameBackground {
		return color.NRGBA{0x30, 0x30, 0x30, 0xff}
	}
	if name == theme.ColorNameScrollBar {
		return color.RGBA{130, 195, 65, 100}
	}
	return theme.DefaultTheme().Color(name, theme.VariantDark)
}
func (m myTheme) Font(style fyne.TextStyle) fyne.Resource {
	return theme.DefaultTheme().Font(style)
}

func (m myTheme) Size(name fyne.ThemeSizeName) float32 {
	if name == theme.SizeNameSeparatorThickness {
		return 2
	}
	return theme.DefaultTheme().Size(name)
}

func (m myTheme) Icon(name fyne.ThemeIconName) fyne.Resource {

	return theme.DefaultTheme().Icon(name)
}
