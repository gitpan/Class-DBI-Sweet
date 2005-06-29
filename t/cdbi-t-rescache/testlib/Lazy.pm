package Lazy;

BEGIN { unshift @INC, './t/cdbi-t/testlib'; }
use base 'CDBase';
use strict;

# __PACKAGE__->table("Lazy");
__PACKAGE__->columns('Primary',   qw(this));
__PACKAGE__->columns('Essential', qw(opop));
__PACKAGE__->columns('things',    qw(this that));
__PACKAGE__->columns('horizon',   qw(eep orp));
__PACKAGE__->columns('vertical',  qw(oop opop));

sub CONSTRUCT {
	my $class = shift;
	$class->db_Main->do(
		qq{
    CREATE TABLE lazy (
        this INTEGER,
        that INTEGER,
        eep  INTEGER,
        orp  INTEGER,
        oop  INTEGER,
        opop INTEGER
    )
  }
	);
}

1;

