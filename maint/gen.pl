use strict;
use warnings;

my @list = sort map { chomp; s/\.pm$//; s/^lib\///; s/\//::/g; $_ } `find lib -name \*.pm`;

open my $fh, '>', 't/01_use.t';

print $fh <<'EOM';
use Test2::V0 -no_srand => 1;

sub require_ok ($);

EOM

foreach my $module (@list)
{
  print $fh "require_ok '$module';\n";
}

foreach my $module (@list)
{
  my $test = lc $module;
  $test =~ s/::/_/g;
  $test = "t/$test.t";
  printf $fh "ok -f %-55s %s\n", "'$test',", "'test for $module';";
}

print $fh <<'EOM';
done_testing;

sub require_ok ($)
{
  # special case of when I really do want require_ok.
  # I just want a test that checks that the modules
  # will compile okay.  I won't be trying to use them.
  my($mod) = @_;
  my $name = "require $mod";
  my $ctx = context();
  my $pm = "$mod.pm";
  $pm =~ s/::/\//g;
  eval { require $pm };
  my $error = $@;
  $error
    ? $ctx->fail_and_release($name, "error: $error")
    : $ctx->pass_and_release($name);
}
EOM

close $fh;

#system 'perltidy -b -i=2 -l=900 t/01_use.t';
#unlink 't/01_use.t.bak';


{
  sub run
  {
    my(@cmd) = @_;
    print "% @cmd\n";
    system @cmd;
    die 'command failed' if $?;
  }
  use autodie;
  mkdir 'corpus/dist2' unless -d 'corpus/dist2';
  chdir 'corpus/dist2';
  run 'rm', '-rf', 'foo', 'foo.tar';
  mkdir 'foo';
  run 'git', -C => 'foo', 'init';
  open my $fh, '>', 'foo/foo.txt';
  print $fh "xx\n";
  close $fh;
  run 'git', -C => 'foo', 'add', '.';
  run 'git', -C => 'foo', 'commit', -m => 'yy';
  run 'git', -C => 'foo', 'archive', '--prefix=foo-1.00/', -o => '../foo.tar', 'master';
  run 'rm', '-rf', 'foo';
  chdir '../..';
}


