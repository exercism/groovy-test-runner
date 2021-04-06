class ExampleAllFail {

    private final int year

    ExampleAllFail(int year) {
        this.year = year
    }

    boolean isLeapYear() {
        (year % 2) == 1
    }

}
