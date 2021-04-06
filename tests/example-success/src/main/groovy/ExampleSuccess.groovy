class ExampleSuccess {

    private final int year

    ExampleSuccess(int year) {
        this.year = year
    }

    boolean isLeapYear() {
        (year % 4) == 0 && ((year % 400) == 0 || (year % 100) != 0)
    }

}
