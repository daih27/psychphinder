package main

import (
	"log"
	"regexp"
	"strings"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/data/binding"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/widget"
	fuzzy "github.com/paul-mannino/go-fuzzywuzzy"
)

var line []phrase

func clear(display *widget.Entry) {
	display.Text = ""
	display.Refresh()
}

func Search(text2 string) ([]phrase, []string) {
	dataSearch := []phrase{}
	DataForList := []string{}
	re, err := regexp.Compile("[^0-9a-zA-Z ]+")

	if err != nil {
		log.Fatal(err)
	}
	text2 = re.ReplaceAllString(text2, "")
	for i := 1; i < len(line); i++ {
		found := re.ReplaceAllString(line[i].match, "")
		found = strings.ReplaceAll(found, "  ", " ")
		found = strings.ReplaceAll(found, "   ", " ")
		if fuzzy.TokenSetRatio(strings.ToLower(text2), strings.ToLower(found)) >= 80 && len(found) >= len(text2)-2 {
			result := line[i]
			dataSearch = append(dataSearch, result)
			DataForList = append(DataForList, line[i].match)
		}
	}
	return dataSearch, DataForList
}

func main() {
	myApp := app.NewWithID("com.github.psychphinder")
	myApp.Settings().SetTheme(&myTheme{})
	myWindow := myApp.NewWindow("psychphinder")

	line = ReadData() // Read data here only one time

	ButtonTitle, listData, NoResults := makeListTab()
	// Load logo
	image := canvas.NewImageFromResource(resourceLogoPng)
	image.FillMode = canvas.ImageFillContain
	image.SetMinSize(fyne.NewSize(360, 360*306/1399))
	// Set content
	Content := fyne.NewContainerWithLayout(layout.NewBorderLayout(ButtonTitle, nil, nil, nil),
		ButtonTitle, listData, NoResults)
	ui := fyne.NewContainerWithLayout(layout.NewBorderLayout(image, nil, nil, nil),
		image, Content)
	myWindow.SetContent(ui)
	//myWindow.Resize(fyne.Size{Height: 600, Width: 400})
	myWindow.ShowAndRun()
}

func makeListTab() (fyne.CanvasObject, fyne.CanvasObject, fyne.CanvasObject) {
	var dataList []phrase
	var DataListLabel []string
	var list *widget.List
	var split *fyne.Container
	var EpisodeText *widget.Label
	dataBinding := binding.BindStringList(&DataListLabel) // Used to update list when a new search is done

	// Create labels
	NoResults := widget.NewLabelWithStyle("No results were found, c'mon son.", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	TitleSearch := widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	TimeSearch := widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	BeforeSearch := widget.NewLabel("")
	AfterSearch := widget.NewLabel("")
	MatchSearch := widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	SeasonText := widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	EpisodeText = widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})

	// Wraps text in more lines when it's too long
	TitleSearch.Wrapping = fyne.TextWrapWord
	BeforeSearch.Wrapping = fyne.TextWrapWord
	AfterSearch.Wrapping = fyne.TextWrapWord
	MatchSearch.Wrapping = fyne.TextWrapWord

	// Search box
	input := widget.NewEntry()
	input.SetPlaceHolder("Enter text...")
	// Search button
	button := container.NewVBox(input, widget.NewButton("Search", func() {
		// Search data when button is pressed
		dataList, DataListLabel = Search(input.Text)
		// Clear Entry Box
		clear(input)
		// Reload list data
		dataBinding.Reload()
		// Reload episode info
		list.Unselect(0)
		list.Select(0)
		// Hide when nothing is found
		if len(DataListLabel) == 0 {
			split.Hide()
			NoResults.Show()
		} else {
			split.Show()
			NoResults.Hide()
		}
	}))
	//Create list with search results
	list = widget.NewListWithData(dataBinding,
		func() fyne.CanvasObject {
			return widget.NewLabel("template")
		},
		func(i binding.DataItem, o fyne.CanvasObject) {
			o.(*widget.Label).Bind(i.(binding.String))
		})

	list.OnSelected = func(id widget.ListItemID) {
		TitleSearch.SetText(dataList[id].title)
		TimeSearch.SetText(dataList[id].time)
		BeforeSearch.SetText(dataList[id].before)
		AfterSearch.SetText(dataList[id].after)
		MatchSearch.SetText(dataList[id].match)
		if (dataList[id].title == "Psych: The Movie") || (dataList[id].title == "Psych 2: Lassie Come Home") {
			EpisodeText.Hide()
			SeasonText.SetText("Movie")
		} else {
			SeasonText.SetText("Season " + dataList[id].season)
			EpisodeText.SetText("Episode " + dataList[id].episode)
			EpisodeText.Show()
		}
	}

	sep := widget.NewSeparator()
	hbox := fyne.NewContainerWithLayout(layout.NewHBoxLayout(), SeasonText, EpisodeText, layout.NewSpacer(), TimeSearch)
	vbox := fyne.NewContainerWithLayout(layout.NewVBoxLayout(), BeforeSearch, MatchSearch, AfterSearch)
	content := container.NewVBox(sep, sep, sep, TitleSearch, hbox, layout.NewSpacer(), vbox, layout.NewSpacer())
	split = container.New(layout.NewBorderLayout(nil, content, nil, nil), list, content)
	split.Hide()
	NoResults.Hide()

	return button, split, NoResults
}
