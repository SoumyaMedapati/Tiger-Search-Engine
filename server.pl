#!/usr/bin/perl -w
# Filename : server.pl
#use strict;
use Socket;
use storable;

# setting up port and ip address
# use different iP if you are dedicated to a server box
my $port   = shift || 8001;
my $proto  = getprotobyname('tcp');
my $server = "localhost";
socket( SOCKET, PF_INET, SOCK_STREAM, $proto )
  or die "Can't open socket $!\n";

# creating socket with the given ip and port values
setsockopt( SOCKET, SOL_SOCKET, SO_REUSEADDR, 1 )
  or die "something wrong with port and ip address check once $!\n";
bind( SOCKET, pack_sockaddr_in( $port, inet_aton($server) ) )
  or die "Can't bind to port $port! \n";
listen( SOCKET, 5 ) or die "listen: $!";
print "server running on port # $port\n";
print "Please wait till server is setup for users request\n";
print " ********************************************************\n";

@Docs = <./PreprocessedFiles/*>;

$DOCS = scalar(@Docs);

#calculating term frequency
foreach $Doc (@Docs) {
	open( INPUT, "<$Doc" ) || die "Can't open $Doc<br>";
	undef $/;
	while (<INPUT>) {
		@words = split( '\s+', $_ );
		foreach $word (@words) {
			$termfreq{$word}{$Doc}++;
		}
	}
}

my $N = $DOCS;
foreach $word ( keys %termfreq ) {
	$i = 0;

	foreach $Doc ( keys %{ $termfreq{$word} } ) {

		$indexterm{$word}[$i] = $Doc;
		$i++;
		$m = scalar( keys %{ $termfreq{$word} } );
		$idf{$word} = log( $N / $m );

	}
}
foreach $word ( keys %termfreq ) {
	$I = $idf{$word};
	foreach $Doc ( keys %{ $termfreq{$word} } ) {
		$C = $termfreq{$word}{$Doc};
		if ( !exists( $length{$Doc} ) ) {
			$length{$Doc} = 0;
		}
		$length{$Doc} = $length{$Doc} + ( ( $I * $C ) * ( $I * $C ) );
	}
}

foreach $word ( keys %termfreq ) {
	$I = $idf{$word};
	foreach $Doc ( keys %{ $termfreq{$word} } ) {
		$C = $termfreq{$word}{$Doc};

		$length{$Doc} = $length{$Doc} + ( ( $I * $C ) * ( $I * $C ) );
	}
}
foreach $Doc ( keys %length ) {
	$length{$Doc} = sqrt( $length{$Doc} );
}

print
"****************************************Ready to accept client requests****************************************************\n";

my $client_addr;
while ( $client_addr = accept( NEW_SOCKET, SOCKET ) ) {

	my $searchInf = "searchInfo.txt";
	open( FH, "< $searchInf" ) or die "Can't open $searchInf for read: $!";
	my @lines;
	while (<FH>) {
		push( @lines, $_ );
	}
	close FH or die "Cannot close $searchInf: $!";

	$query = $lines[0];
	print "\nQuery is $query\n";
	$query =~ s/[[?;:!,.\@Õ~\$%<>\|^&=*'#^+_"`[\]()-]/ /g;
	$query =~ s/^\s+//;
	$query =~ s/\s+$//;
	$query =~ tr/A-Z/a-z/;
	@abc = split( '\s+', $query );
	open( OUTPUT, ">temp.txt" );
	foreach $word (@abc) {
		print OUTPUT "$word\n";
	}
	close(OUTPUT);
	undef $stemQuery;
	chomp( $stemQuery = `perl Preprocessor.pl` );
	print "stem query value $stemQuery";
	$stemQuery =~ s/\n/ /g;
	undef @queryterm;
	@queryterm = split( '\s', $stemQuery );
	
	
	print "\n query preprocessed. calculating TF IDF values  \n";
	undef $queryfreq;

	foreach $word (@queryterm) {
		$queryfreq{$word}++;
	}

	undef %querywght;
	foreach $word (@queryterm) {
		$querywght{$word} = $idf{$word} * $queryfreq{$word};
		print "query wght $querywght{$word} ";
	}

	undef %score;
	undef %R;
	undef @L;
	undef $score;
	foreach $word (@queryterm) {
		if ( exists( $indexterm{$word} ) ) {
			push( @L, @{ $indexterm{$word} } );

			foreach $O (@L) {
				$D = $O;
				$C = $termfreq{$word}{$D};
				if ( !$termfreq{$word}{$D} ) {
					$C = 0;
				}
				if ( !exists( $R{$D} ) ) {
					$R{$D}     = 0;
					$score{$D} = 0;
				}
				$score{$D} =
				  $score{$D} + ( $querywght{$word} * $idf{$word} * $C );
				  print "score of d $D   $score{$D}";
			}
		}
	}
	$sum = 0;
	foreach $word (@queryterm) {
		$sum = $sum + ( $querywght{$word} * $querywght{$word} );
		$L = sqrt($sum);
	}
	undef %norms;
	undef @keys;
	@keys = keys %norms;
	$size = @keys;
	foreach $doc ( keys %R ) {
		$S = $score{$doc};
		$Y = $length{$doc};
		undef $product;
		$product = $L * $Y;

		if ( $product != 0 ) {    
			$norms{$doc} = $S / $product;

		}
		else {
			delete $norms{$doc};
		}

	}
	@keys = keys %norms;
	$size = @keys;

	my $result;
	foreach $doc ( sort { $norms{$b} cmp $norms{$a} } keys %norms ) {
		open my $file, '<', "$doc";
		my $firstLine = <$file>;
		@words = split( "\n", $firstLine );
		close $file;
		if ( index( $norms{$doc}, "e" ) == -1 ) {

			$scoreborad =
			  " (score:" . $norms{$doc} . ")xtempformediator98274";
			my $url       = $words[0];
			my $newresult = $url . $scoreborad;
			$result = $result . $newresult;
		}
	}
	my $name = gethostbyaddr( $client_addr, AF_INET );
	print NEW_SOCKET $result;
	print "Connection recieved from $name\n";
	close NEW_SOCKET;
}
