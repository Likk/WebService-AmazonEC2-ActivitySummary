use inc::Module::Install;
name 'WebService-AmazonEC2-ActivitySummary';
all_from 'lib/WebService/AmazonEC2/ActivitySummary.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
