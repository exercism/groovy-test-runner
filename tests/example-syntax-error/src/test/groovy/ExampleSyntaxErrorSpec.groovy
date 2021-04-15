import spock.lang.*

class ExampleSyntaxErrorSpec extends Specification {

    def "Year not divisible by 4 in common year"() {
        expect:
        new ExampleSyntaxError(year).isLeapYear() == expected

        where:
        year || expected
        2015 || false
    }

    @Ignore
    def "Year divisible by 400 in leap year"() {
        expect:
        new ExampleSyntaxError(year).isLeapYear() == expected

        where:
        year || expected
        2000 || true
    }
}
