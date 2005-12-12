use strict;
use Test::More;
use Class::DBI::Sweet;
Class::DBI::Sweet->default_search_attributes({ use_resultset_cache => 1 });
Class::DBI::Sweet->cache(Cache::MemoryCache->new(
    { namespace => "SweetTest", default_expires_in => 60 } ) ); 

BEGIN {
	eval "use Cache::MemoryCache";
	plan skip_all => "needs Cache::Cache for testing" if $@;
	eval "use DBD::SQLite";
	plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 5);
}

use lib 't/cdbi-t/testlib';
use Film;
use Director;

{ # Cascade Strategies
	Director->has_many(nasties => Film => { cascade => 'Fail' });

	my $dir = Director->insert({ name => "Nasty Noddy" });
	my $kk = $dir->add_to_nasties({ Title => 'Killer Killers' });
	is $kk->director, $dir, "Director set OK";
	is $dir->nasties, 1, "We have one nasty";
	eval { $dir->delete };
	like $@, qr/1/, "Can't delete while films exist";
	my $rr = $dir->add_to_nasties({ Title => 'Revenge of the Revengers' });
	eval { $dir->delete };
	like $@, qr/2/, "Still can't delete";
	$dir->nasties->delete_all;
	eval { $dir->delete };
	is $@, '', "Can delete once films are gone";
}
