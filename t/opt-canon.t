#!perl
use strict;
use warnings;

use Test::More tests => 15;

BEGIN { use_ok('Sub::Exporter'); }

# let's get a convenient copy to use:
Sub::Install::install_sub({
  code => '_canonicalize_opt_list',
  from => 'Sub::Exporter',
  as   => 'CAN',
});

is_deeply(
  CAN([]),
  [],
  "empty opt list expands properly",
);

is_deeply(
  CAN(),
  [],
  "undef expands into []",
);

is_deeply(
  CAN([ qw(foo bar baz) ]),
  [ [ foo => undef ], [ bar => undef ], [ baz => undef ] ],
  "opt list of just names expands",
);

{
  my $options = CAN({ foo => undef, bar => 10, baz => [] });
     $options = [ sort { $a->[0] cmp $b->[0] } @$options ];

  is_deeply(
    $options,
    [ [ bar => undef ], [ baz => [] ], [ foo => undef ] ],
    "hash opt list expands properly"
  );
}

is_deeply(
  CAN([ qw(foo bar baz) ], 0, "ARRAY"),
  [ [ foo => undef ], [ bar => undef ], [ baz => undef ] ],
  "opt list of just names expands with must_be",
);

is_deeply(
  CAN([ qw(foo :bar baz) ]),
  [ [ foo => undef ], [ ':bar' => undef ], [ baz => undef ] ],
  "opt list of names expands with :group names",
);

is_deeply(
  CAN([ foo => { a => 1 }, ':bar', 'baz' ]),
  [ [ foo => { a => 1 } ], [ ':bar' => undef ], [ baz => undef ] ],
  "opt list of names and values expands",
);

is_deeply(
  CAN([ foo => { a => 1 }, ':bar', 'baz' ], 0, 'HASH'),
  [ [ foo => { a => 1 } ], [ ':bar' => undef ], [ baz => undef ] ],
  "opt list of names and values expands with must_be",
);

is_deeply(
  CAN([ foo => { a => 1 }, ':bar', 'baz' ], 0, ['HASH']),
  [ [ foo => { a => 1 } ], [ ':bar' => undef ], [ baz => undef ] ],
  "opt list of names and values expands with [must_be]",
);

eval { CAN([ foo => { a => 1 }, ':bar', 'baz' ], 0, 'ARRAY'); };
like($@, qr/HASH-ref values are not/, "exception tossed on invaild ref value");

eval { CAN([ foo => { a => 1 }, ':bar', 'baz' ], 0, ['ARRAY']); };
like($@, qr/HASH-ref values are not/, "exception tossed on invaild ref value");

is_deeply(
  CAN([ foo => { a => 1 }, ':bar' => undef, 'baz' ]),
  [ [ foo => { a => 1 } ], [ ':bar' => undef ], [ baz => undef ] ],
  "opt list of names and values expands, ignoring undef",
);

eval { CAN([ foo => { a => 1 }, ':bar' => undef, ':bar' ], 1); };
like($@, qr/multiple definitions/, "require_unique constraint catches repeat");

is_deeply(
  CAN([ foo => { a => 1 }, ':bar' => undef, 'baz' ], 1),
  [ [ foo => { a => 1 } ], [ ':bar' => undef ], [ baz => undef ] ],
  "previously tested expansion OK with require_unique",
);
