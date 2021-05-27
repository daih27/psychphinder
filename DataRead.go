package main

import (
	"strings"
)

type phrase struct {
	before  string
	match   string
	after   string
	time    string
	title   string
	season  string
	episode string
}

func ReadData() []phrase {
	data := string(resourceDataTxt.StaticContent)
	data = strings.ReplaceAll(data, "\r", "")
	s := strings.Split(data, ";")
	var nd2 []string
	for i := 0; i < len(s); i++ {
		nd := strings.Split(s[i], "\n")
		if len(nd) == 2 {
			nd2 = append(nd2, nd[0])
			nd2 = append(nd2, nd[1])
		} else {
			nd2 = append(nd2, nd[0])
		}
	}
	result := phrase{}
	dataStruct := []phrase{}
	for i := 0; i < len(nd2)-1; i = i + 5 {
		if i < 5 {
			result = phrase{season: nd2[i],
				episode: nd2[i+1],
				title:   nd2[i+2],
				time:    nd2[i+3],
				after:   nd2[i+9],
				match:   nd2[i+4],
				before:  ""}
		} else {
			if i > len(nd2)-7 {
				result = phrase{season: nd2[i],
					episode: nd2[i+1],
					title:   nd2[i+2],
					time:    nd2[i+3],
					after:   "",
					match:   nd2[i+4],
					before:  nd2[i-1]}
			} else {
				result = phrase{season: nd2[i],
					episode: nd2[i+1],
					title:   nd2[i+2],
					time:    nd2[i+3],
					after:   nd2[i+9],
					match:   nd2[i+4],
					before:  nd2[i-1]}
			}
		}
		dataStruct = append(dataStruct, result)
	}
	return dataStruct
}
