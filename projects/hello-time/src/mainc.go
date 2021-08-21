package main

// int number() {
//     return 2;
// }
import "C"
import "time"

func main() {
	loc, _ := time.LoadLocation("Europe/Budapest")
	println(
		"Hello Go!",
		C.number(),
		time.Date(2021, time.August, 20, 12, 0, 0, 0, loc).Format(time.RFC3339),
	)
}
