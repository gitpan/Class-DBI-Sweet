use strict;
use warnings;

use Test::More tests => 6;

eval "use Cache::MemoryCache";

plan skip_all => 'Cache::Cache required' if $@;

use lib 't/lib';

use_ok('SweetTest');

SweetTest->cache(Cache::MemoryCache->new(
    { namespace => 'SweetTest', default_expires_in => 60 } ) );

SweetTest->default_search_attributes(
    { use_resultset_cache => 1,
      profile_cache => 1 });

SweetTest->profiling_data({ });

my ($cd) = SweetTest::CD->search( { 'cdid' => 2 },
                                 { prefetch => [ qw/artist liner_notes/ ] });

use Data::Dumper; print Dumper(SweetTest->profiling_data->{object_cache});

cmp_ok(scalar @{SweetTest->profiling_data->{object_cache} || []}, '==', 4,
    'Three objects created from query');

SweetTest::CD->profiling_data({ });

is($cd->artist->name, 'Caterwauler McCrae', 'artist has_a ok');

cmp_ok(scalar @{SweetTest::CD->profiling_data->{object_cache} || []}, '==', 0,
    'No fetch required for has_a');

is($cd->liner_notes->notes, 'Buy Whiskey!', 'liner_notes might_have ok');

cmp_ok(scalar SweetTest::CD->profiling_data->{object_cache}, '==', 0,
    'No fetch required for might_have');

use Data::Dumper qw/Dumper/;
print Dumper(SweetTest::CD->profiling_data);
