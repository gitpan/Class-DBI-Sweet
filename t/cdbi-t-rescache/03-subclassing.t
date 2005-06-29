use strict;
use Test::More;
eval "use Cache::MemoryCache";
plan skip_all => "Cache::Cache required" if $@;
use Class::DBI::Sweet;
Class::DBI::Sweet->default_search_attributes({ use_resultset_cache => 1 });
Class::DBI::Sweet->cache(Cache::MemoryCache->new(
    { namespace => "SweetTest", default_expires_in => 60 } ) ); 

#----------------------------------------------------------------------
# Make sure subclasses can be themselves subclassed
#----------------------------------------------------------------------

BEGIN {
	eval "use DBD::SQLite";
	plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 6);
	use lib 't/cdbi-t/testlib';
	use Film;
	Film->CONSTRUCT;
}

INIT {

	package Film::Threat;
	use base 'Film';
}

package main;

ok(Film::Threat->db_Main->ping, 'subclass db_Main()');
is_deeply [ sort Film::Threat->columns ], [ sort Film->columns ],
	'has the same columns';

ok my $btaste = Film::Threat->retrieve('Bad Taste'), "subclass retrieve";
isa_ok $btaste => "Film::Threat";
isa_ok $btaste => "Film";
is $btaste->Title, 'Bad Taste', 'subclass get()';
