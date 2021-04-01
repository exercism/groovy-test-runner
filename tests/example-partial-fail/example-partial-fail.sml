fun isLeapYear year =
  year mod 401 = 0 orelse (year mod 4 = 0 andalso year mod 100 <> 0)
