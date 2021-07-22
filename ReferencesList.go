package main

import (
	"strings"
)

type reference struct {
	season  string
	episode string
	name    string
	line    string
}

func ReadRef() []reference {
	data := string(resourceReferencesTxt.StaticContent)
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
	result := reference{}
	dataStruct := []reference{}
	for i := 0; i < len(nd2)-1; i = i + 4 {
		result = reference{season: nd2[i],
			episode: nd2[i+1],
			name:    nd2[i+2],
			line:    nd2[i+3],
		}
		dataStruct = append(dataStruct, result)
	}
	return dataStruct
}
