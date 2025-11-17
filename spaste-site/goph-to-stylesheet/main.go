package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/olekukonko/tablewriter"
	flag "github.com/spf13/pflag"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

type Goph struct {
	Themes []Themes `json:"themes"`
}
type Themes struct {
	Name         string `json:"name"`
	Black        string `json:"black"`
	Red          string `json:"red"`
	Green        string `json:"green"`
	Yellow       string `json:"yellow"`
	Blue         string `json:"blue"`
	Purple       string `json:"purple"`
	Cyan         string `json:"cyan"`
	White        string `json:"white"`
	BrightBlack  string `json:"brightBlack"`
	BrightRed    string `json:"brightRed"`
	BrightGreen  string `json:"brightGreen"`
	BrightYellow string `json:"brightYellow"`
	BrightBlue   string `json:"brightBlue"`
	BrightPurple string `json:"brightPurple"`
	BrightCyan   string `json:"brightCyan"`
	BrightWhite  string `json:"brightWhite"`
	Foreground   string `json:"foreground"`
	Background   string `json:"background"`
	CursorColor  string `json:"cursorColor"`
}

func main() {
	theme := flag.StringP("theme", "t", "Molokai", "goph theme")
	inputFile := flag.StringP("input", "i", "template.scss", "source file for replacement")
	outputFile := flag.StringP("output", "o", "goph.scss", "output file for replacement")
	flag.Parse()

	goph, err := fetch()
	if err != nil {
		log.Fatalf("fetch error : %v", err)
	}

	var tf bool
	for _, t := range goph.Themes {
		if t.Name == *theme {
			fmt.Printf("theme '%v' found :\n", *theme)

			tf = true
			table := tablewriter.NewWriter(os.Stdout)
			table.SetHeader([]string{"COLOR", "HEX"})
			table.Append([]string{"black", t.Black})
			table.Append([]string{"red", t.Red})
			table.Append([]string{"green", t.Green})
			table.Append([]string{"yellow", t.Yellow})
			table.Append([]string{"blue", t.Black})
			table.Append([]string{"purple", t.Purple})
			table.Append([]string{"cyan", t.Cyan})
			table.Append([]string{"white", t.White})
			table.Append([]string{"brightBlack", t.BrightBlack})
			table.Append([]string{"brightRed", t.BrightRed})
			table.Append([]string{"brightGreen", t.BrightGreen})
			table.Append([]string{"brightYellow", t.BrightYellow})
			table.Append([]string{"brightBlue", t.BrightBlue})
			table.Append([]string{"brightPurple", t.BrightPurple})
			table.Append([]string{"brightCyan", t.BrightCyan})
			table.Append([]string{"brightWhite", t.BrightWhite})
			table.Append([]string{"foreground", t.Foreground})
			table.Append([]string{"background", t.Background})
			table.Append([]string{"cursorColor", t.CursorColor})
			table.Render()

			input, err := ioutil.ReadFile(*inputFile)
			if err != nil {
				log.Fatalf("read error : %v", err)
			}

			output := replaceColor(t, input)

			err = ioutil.WriteFile(*outputFile, output, 0666)
			if err != nil {
				log.Fatalf("output error : %v\n", err)
			}
			fmt.Printf("Saved to %v\n", *outputFile)
		}
	}
	if !tf {
		fmt.Printf("theme '%v' not found in goph\n", *theme)
	}
}

func fetch() (Goph, error) {
	url := "https://raw.githubusercontent.com/Mayccoll/Gogh/master/data/themes.json"
	resp, err := http.Get(url)
	if err != nil {
		return Goph{}, err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return Goph{}, err
	}

	var goph Goph
	err = json.Unmarshal(body, &goph)
	if err != nil {
		return Goph{}, err
	}

	return goph, nil
}

func replaceColor(t Themes,input []byte) ([]byte){
	black := bytes.Replace(input, []byte("[[black]]"), []byte(t.Black), -1)
	red := bytes.Replace(black, []byte("[[red]]"), []byte(t.Red), -1)
	green := bytes.Replace(red, []byte("[[green]]"), []byte(t.Green), -1)
	yellow := bytes.Replace(green, []byte("[[yellow]]"), []byte(t.Yellow), -1)
	blue := bytes.Replace(yellow, []byte("[[blue]]"), []byte(t.Blue), -1)
	purple := bytes.Replace(blue, []byte("[[purple]]"), []byte(t.Purple), -1)
	cyan := bytes.Replace(purple, []byte("[[cyan]]"), []byte(t.Cyan), -1)
	white := bytes.Replace(cyan, []byte("[[white]]"), []byte(t.White), -1)
	brightBlack := bytes.Replace(white, []byte("[[brightBlack]]"), []byte(t.BrightBlack), -1)
	brightRed := bytes.Replace(brightBlack, []byte("[[brightRed]]"), []byte(t.BrightRed), -1)
	brightGreen := bytes.Replace(brightRed, []byte("[[brightGreen]]"), []byte(t.BrightGreen), -1)
	brightYellow := bytes.Replace(brightGreen, []byte("[[brightYellow]]"), []byte(t.BrightYellow), -1)
	brightBlue := bytes.Replace(brightYellow, []byte("[[brightBlue]]"), []byte(t.BrightBlue), -1)
	brightPurple := bytes.Replace(brightBlue, []byte("[[brightPurple]]"), []byte(t.BrightPurple), -1)
	brightCyan := bytes.Replace(brightPurple, []byte("[[brightCyan]]"), []byte(t.BrightCyan), -1)
	brightWhite := bytes.Replace(brightCyan, []byte("[[brightWhite]]"), []byte(t.BrightWhite), -1)
	foreground := bytes.Replace(brightWhite, []byte("[[foreground]]"), []byte(t.Foreground), -1)
	background := bytes.Replace(foreground, []byte("[[background]]"), []byte(t.Background), -1)
	cursorColor := bytes.Replace(background, []byte("[[cursorColor]]"), []byte(t.CursorColor), -1)
	return cursorColor
}
