(* version 1.4.0 *)

use "testlib.sml";
use "example-all-fail.sml";

infixr |>
fun x |> f = f x

val testsuite =
  describe "leap" [
    test "year not divisible by 4: common year"
      (fn _ => isLeapYear (2015) |> Expect.falsy),

    test "year divisible by 4, not divisible by 100: leap year"
      (fn _ => isLeapYear (1996) |> Expect.truthy)
  ]

val _ = Test.run testsuite
