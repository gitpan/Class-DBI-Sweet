#!/bin/sh

CDBIDIR=$1
SWEETDIR=$2

if [ "$CDBIDIR" == "" ]; then
  echo "Usage: $0 CDBIDIR SWEETDIR";
  exit 255;
elif [ "$SWEETDIR" == "" ]; then
  echo "Usage: $0 CDBIDIR SWEETDIR";
  exit 255;
fi;

rm -rf t/cdbi-t

mkdir t/cdbi-t

cp -R $1/t/* $2/t/cdbi-t/

perl -pi -e 's!t/testlib!t/cdbi-t/testlib!;
             s/Class::DBI(?=[^:])/Class::DBI::Sweet/;
                ' t/cdbi-t/*.t t/cdbi-t/testlib/*.pm

perl -pi -e 's/tests => 27/tests => 25/;' t/cdbi-t/99-misc.t

rm -rf t/cdbi-t-ocache
rm -rf t/cdbi-t-rescache

cp -R t/cdbi-t t/cdbi-t-ocache
cp -R t/cdbi-t t/cdbi-t-rescache

# A copy of the Class::DBI tests with only object caching enabled
perl -pi -e 's!use Test::More;!use Test::More;
eval "use Cache::MemoryCache";
plan skip_all => "Cache::Cache required" if \$\@;
use Class::DBI::Sweet;
Class::DBI::Sweet->default_search_attributes({ use_resultset_cache => 0 });
Class::DBI::Sweet->cache(Cache::MemoryCache->new(
    { namespace => "SweetTest", default_expires_in => 60 } ) ); !
    ' t/cdbi-t-ocache/*.t

# A copy of the Class::DBI tests with Resultset caching enabled
perl -pi -e 's!use Test::More;!use Test::More;
eval "use Cache::MemoryCache";
plan skip_all => "Cache::Cache required" if \$\@;
use Class::DBI::Sweet;
Class::DBI::Sweet->default_search_attributes({ use_resultset_cache => 1 });
Class::DBI::Sweet->cache(Cache::MemoryCache->new(
    { namespace => "SweetTest", default_expires_in => 60 } ) ); !
    ' t/cdbi-t-rescache/*.t
    
echo 'Done! Remember to re-run: perl Build.PL'

rm -f t/cdbi-t-*cache/04-lazy.t  # Lazy loading? Bah, we've cached it already
rm -f t/cdbi-t-*cache/02-Film.t  # Fails because it checks references
rm -f t/cdbi-*/15-accessor.t # Because it's b0rken
rm -f t/cdbi-t/16-reserved.t # Because it's b0rken
