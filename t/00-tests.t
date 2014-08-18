use Test::More tests => 2;
 
BEGIN {
    use_ok( 'App::Enslide' );
}

 
diag( "Testing App::Enslide $App::Enslide::VERSION, Perl $], $^X" );

{
	my $a = App::Enslide->new();
	ok(defined $a, 'An object was created');
}
__END__

{
	#my $a = App::Enslide->new();
	#$a->run('-h');
	#ok(defined $a, 'An object was created');
}
