@IsTest
private class StringHelperTest {

    @IsTest
    static void truncate_returnsNullForNull() {
        System.assertEquals(null, StringHelper.truncate(null, 5));
    }

    @IsTest
    static void truncate_returnsValueWhenShorter() {
        System.assertEquals('abc', StringHelper.truncate('abc', 10));
    }

    @IsTest
    static void truncate_cutsValueToMaxLen() {
        System.assertEquals('abcde', StringHelper.truncate('abcdefghij', 5));
    }

    @IsTest
    static void truncate_throwsOnNegativeMaxLen() {
        Boolean threw = false;
        try {
            StringHelper.truncate('abc', -1);
        } catch (StringHelper.IllegalArgumentException e) {
            threw = true;
        }
        System.assert(threw, 'Negative maxLen should throw.');
    }

    @IsTest
    static void slugify_lowercasesAndReplacesNonAlphanumeric() {
        System.assertEquals('hello-world-2026', StringHelper.slugify('Hello, World! 2026'));
    }

    @IsTest
    static void slugify_trimsLeadingAndTrailingDashes() {
        System.assertEquals('mid-section', StringHelper.slugify('---Mid section---'));
    }

    @IsTest
    static void slugify_returnsEmptyForBlank() {
        System.assertEquals('', StringHelper.slugify(null));
        System.assertEquals('', StringHelper.slugify('   '));
    }

    @IsTest
    static void defaultIfBlank_returnsFallbackForBlank() {
        System.assertEquals('fallback', StringHelper.defaultIfBlank(null, 'fallback'));
        System.assertEquals('fallback', StringHelper.defaultIfBlank('  ', 'fallback'));
    }

    @IsTest
    static void defaultIfBlank_returnsValueForNonBlank() {
        System.assertEquals('actual', StringHelper.defaultIfBlank('actual', 'fallback'));
    }
}