#!/bin/bash
fyne bundle metadata/data.txt > bundled.go
fyne bundle -append metadata/logo.png >> bundled.go