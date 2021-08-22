package main

import "time"

func main() {
	loc, _ := time.LoadLocation("Europe/Budapest")
	println(
		"Hello Go!",
		time.Date(2021, time.August, 20, 12, 0, 0, 0, loc).Format(time.RFC3339),
	)
}
