package main

// int number() {
//     return 2;
// }
import "C"

func main() {
	println("Hello Go!", C.number())
}
