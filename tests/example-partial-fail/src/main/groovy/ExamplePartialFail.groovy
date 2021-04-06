class ExamplePartialFail {

    private final int year

    ExamplePartialFail(int year) {
        this.year = year
    }

    boolean isLeapYear() {
        (year % 4) == 0 && ((year % 401) == 0 || (year % 100) != 0)
    }

}
