use strict;
use warnings;

use Test::More tests => 2;

use lib 't/lib';

use_ok('SweetTest');

SweetTest::CD->sequence( 'uuid' );

like( SweetTest::CD->_next_in_sequence, 
    qr/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/, "uuid ok" );
