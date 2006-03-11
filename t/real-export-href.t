#!perl
use strict;
use warnings;

use Test::More tests => 23;

BEGIN { use_ok('Sub::Exporter'); }

use lib 't/lib';

{
  package Test::SubExporter::BUILT;

  my $import = Sub::Exporter::build_exporter({ exports => [ 'X' ] });

  Sub::Exporter::setup_exporter({
    exports => [ 'X' ],
    into    => 'Test::SubExporter::VIOLATED',
    as      => 'gimme_X_from',
  });

  sub X { return "expected" }

  package Test::SubExporter::BUILT::CONSUMER;

  $import->('Test::SubExporter::BUILT', ':all');
  main::is(X(), "expected", "manually constructed importer worked");

  package Test::SubExporter::VIOLATED;

  gimme_X_from('Test::SubExporter::BUILT', ':all');
  main::is(X(), "expected", "manually constructed importer worked");
}

package Test::SubExporter::DEFAULT;
main::use_ok('Test::SubExportA');
use subs qw(xyzzy hello_sailor);

main::is(
  xyzzy,
  "Nothing happens.",
  "DEFAULT: default export xyzzy works as expected"
);

main::is(
  hello_sailor,
  "Nothing happens yet.",
  "DEFAULT: default export hello_sailor works as expected"
);

package Test::SubExporter::RENAME;
main::use_ok('Test::SubExportA', xyzzy => { -as => 'plugh' });
use subs qw(plugh);

main::is(
  plugh,
  "Nothing happens.",
  "RENAME: default export xyzzy=>plugh works as expected"
);

package Test::SubExporter::SAILOR;
main::use_ok('Test::SubExportA', ':sailor');
use subs qw(xyzzy hs_works hs_fails);

main::is(
  xyzzy,
  "Nothing happens.",
  "SAILOR: default export xyzzy works as expected"
);

main::is(
  hs_works,
  "Something happens!",
  "SAILOR: hs_works export works as expected"
);

main::is(
  hs_fails,
  "Nothing happens yet.",
  "SAILOR: hs_fails export works as expected"
);

package Test::SubExporter::Z3;
main::use_ok('Test::SubExportA', hello_sailor => { game => 'zork3' });
use subs qw(hello_sailor);

main::is(
  hello_sailor,
  "Something happens!",
  "Z3: custom hello_sailor works as expected"
);

package Test::SubExporter::FROTZ_SAILOR;
main::use_ok('Test::SubExportA', -sailor => { -prefix => 'frotz_' });
use subs map { "frotz_$_" }qw(xyzzy hs_works hs_fails);

main::is(
  frotz_xyzzy,
  "Nothing happens.",
  "FROTZ_SAILOR: default export xyzzy works as expected"
);

main::is(
  frotz_hs_works,
  "Something happens!",
  "FROTZ_SAILOR: hs_works export works as expected"
);

main::is(
  frotz_hs_fails,
  "Nothing happens yet.",
  "FROTZ_SAILOR: hs_fails export works as expected"
);

package Test::SubExporter::Z3_REF;

my $hello;
main::use_ok(
  'Test::SubExportA',
  hello_sailor => { game => 'zork3', -as => \$hello }
);

eval "hello_sailor;";
main::like(
  $@,
  qr/Bareword "hello_sailor" not allowed/,
  "Z3_REF: hello_sailor isn't actually imported to package"
);

main::is(
  $hello->(),
  "Something happens!",
  "Z3_REF: hello_sailor properly exported to scalar ref",
);

package Test::SubExporter::Z3_BADREF;

main::require_ok('Test::SubExportA');

eval {
  Test::SubExportA->import(hello_sailor => { game => 'zork3', -as => {} });
};

main::like(
  $@,
  qr/invalid reference type/,
  "can't pass a non-scalar ref to -as",
);
