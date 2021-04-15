import spock.lang.*

class ExampleEmptyFileSpec extends Specification {

    def "Year not divisible by 4 in common year"() {
        expect:
        new ExampleEmptyFile(year).isLeapYear() == expected

        where:
        year || expected
        2015 || false
    }

    @Ignore
    def "Year divisible by 400 in leap year"() {
        expect:
        new ExampleEmptyFile(year).isLeapYear() == expected

        where:
        year || expected
        2000 || true
    }
}
