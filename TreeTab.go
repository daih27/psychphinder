package main

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/widget"
)

func makeTreeTab() fyne.CanvasObject {
	var splitRef *fyne.Container
	ReferenceText := widget.NewLabel("")
	ReferenceText.Wrapping = fyne.TextWrapWord

	data := map[string][]string{
		"": {"Season 1", "Season 2", "Season 3", "Season 4", "Season 5", "Season 6", "Season 7"},
	}
	references := ReadRef()
	AllEpisode := []string{}
	AllSeason := []string{}
	for i := 0; i < len(references); i++ {
		// Episode change
		if i > 0 && references[i].name != references[i-1].name {
			AllSeason = append(AllSeason, references[i-1].episode+" - "+references[i-1].name)
			AllEpisode = nil
			AllEpisode = append(AllEpisode, references[i].line)
			data[references[i].episode+" - "+references[i].name] = AllEpisode
			// Season change
			if references[i].season != references[i-1].season {
				data["Season "+references[i-1].season] = AllSeason
				AllSeason = nil
			}
		} else {
			AllEpisode = append(AllEpisode, references[i].line)
			data[references[i].episode+" - "+references[i].name] = AllEpisode
			if i == len(references)-1 {
				AllSeason = append(AllSeason, references[i-1].episode+" - "+references[i-1].name)
			}
		}
		if i == len(references)-1 {
			data["Season "+references[i].season] = AllSeason
		}
	}

	tree := widget.NewTreeWithStrings(data)
	tree.OnSelected = func(id string) {
		for i := 0; i < len(references); i++ {
			if references[i].line == id {
				ReferenceText.SetText(references[i].line)
				splitRef.Show()
			}
		}
	}
	sep := widget.NewSeparator()
	content := container.NewVBox(sep, sep, sep, ReferenceText)
	splitRef = container.New(layout.NewBorderLayout(nil, content, nil, nil), tree, content)
	splitRef.Hide()
	return splitRef
}
