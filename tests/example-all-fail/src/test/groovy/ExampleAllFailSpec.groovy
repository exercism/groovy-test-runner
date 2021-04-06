import spock.lang.*

class ExampleAllFailSpec extends Specification {

    def "Year not divisible by 4 in common year"() {
        expect:
        new ExampleAllFail(year).isLeapYear() == expected

        where:
        year || expected
        2015 || false
    }

    @Ignore
    def "Year divisible by 400 in leap year"() {
        expect:
        new ExampleAllFail(year).isLeapYear() == expected

        where:
        year || expected
        2000 || true
    }
}
