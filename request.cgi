use IO::Socket;
use Data::Dumper;
use warnings;
my $start = time;
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
   @pairs = split(/&/, $buffer);
   foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);
   $value =~ tr/+/ /;
   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/
   pack("C", hex($1))/eg;
   $FORM{$name} = $value;
   }
}
print "Content-type:text/html\n\r\n\r";
$query=$FORM{Text1};
open(URLINSERT, ">searchInfo.txt") || die  "can't open the file";
print URLINSERT "$query";
close (URLINSERT);
@Docs=<./PreprocessedFiles10k/*>;
no warnings;
$totalDocs =scalar(@Docs);
 

 
print <<EndHTML; 

 
<center class="newStyle2">
 
<h3 class="newStyle1" style="color:blue">Tiger Search</h3>
 
 
<form class="style3" method="POST" action="request.cgi">
	<input class="style2" name="Text1" type="text" size= 60>&nbsp;

<input type="submit" value="Search"></center>
<p class="style1"> 
</form>
&nbsp;</p>


EndHTML
print "<h4 style=Blue> Search query is : <i>  $query </i> </h4>"; 

# initialize host and port
my $host = shift || 'localhost';
my $port = shift || 8001;
my $server = "localhost";  # Host IP running the server

# create the socket, connect to the port
socket(SOCKET,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2])
   or die "Can't create a socket $!\n";
connect( SOCKET, pack_sockaddr_in($port, inet_aton($server)))
   or die "Can't connect to port $port! \n";

#my $line;
while (my $line = <SOCKET>) {
#print "$line <br>";
	
 	my $duration = time - $start;
 	#my @lines = split /\n/, $line;
 	my @lines =split( 'xtempformediator98274', $line);
 	my $size =@lines;
 	print "<i>About $size results ($duration seconds)</i>";
my $count=0;
foreach my $lineby (@lines) {
   $count++;
	
	my @Values = split /\s/, $lineby;
	
	print " <h4> [$count] <a href=\"@Values[0] \"> @Values[0]</a> @Values[1] </h3>";

	
}
       # print "$line\n";
        
}
close SOCKET or die "close: $!";
 
 

 