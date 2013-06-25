https://github.com/kylebuckingham/Perl_Zone_Creator.git

#!/opt/csw/bin/perl
# Purpose: web based tool for host and ip dns queries.

use strict;
use CGI;
use CGI::Pretty;
use CGI::Carp('fatalsToBrowser');
use POSIX qw/strftime/;

my $serial = strftime("%Y%m%d", localtime(time));
$serial .= "01";
my $dig = "/usr/sbin/dig";
my $q = CGI->new;
my $self = $q->url;

  print $q->header;
  print $q->start_html( -title => "online zone creator", );
  print qq(<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>\n);
  print $q->h2("DNS Zone File Creator");

  print $q->start_form(-name => "loop");

  print $q->p("Enter your user email");
        print $q->textfield(-name => "username",
                                -size => "30",
                                -default =>'username.example.com');
  print $q->p("Enter the domain or subdomain which you would like to add:");
        print $q->textfield(-name => "zone",
                                -size => "30",
                                -default =>'www.example.com');
  print $q->p("Serial version of the file (usually a date):");
        print $q->textfield(-name => "serial",
                                -size => "30",
                                -default =>"$serial");
  print $q->p("Refresh time:");
        print $q->textfield(-name => "refresh",
                                -size => "10",
                                -default =>'3600');
  print $q->p("Retry time:");
        print $q->textfield(-name => "retry",
                                -size => "10",
                                -default =>'3600');
  print $q->p("Expire time:");
        print $q->textfield(-name => "expire",
                                -size => "10",
                                -default =>'3600');
  print $q->p("Minimum negative TTL:");
        print $q->textfield(-name => "TTL",
                                -size => "10",
                                -default =>'7200');

  print $q->p("Select the type of record which you would like to add:");
  print "<div class='duplicateme' style='display:block;'>";
  print "<tr>";
        print "<td style='padding: 20px 10px 10px 10px;'>";
                print $q->p("Record type");
                        print $q->p($q->popup_menu(-name => 'zonetype', -id => 'form1',
                                 -'values' =>['A','AAAA','CNAME','MX','NS'],
                                 -default =>'A'));
        print "</td>";
        print "<td>";
                print $q->p("Enter the record name");
                        print $q->textfield(-name => "recordID", -id => 'form2',
                                -size => "30",
                                -default =>'www.example.com');
        print "</td>";
        print "<td>";
                print $q->p("Enter the corresponding record name (in name) or IP Address");
                        print $q->textfield(-name => "recordIDin", -id => 'form3',
                                -size => "30",
                                -default =>'192.168.0.1');
        print "</td>";
        print "</tr>";
        print "</table>";
  print "</div>";
  print $q->br;
  print $q->button({-id=>"addrecord", -value=>"Add Record"});
  print $q->submit({-class=>"submit", -name=>"loop", -value=>"Create My Zone File!"});
  print $q->hr;
  print $q->h2("Here is your zone file for: ". $q->param('zone'));
  print <<EOD;
  <table>
    <tr>
      <td>
        <pre>
EOD
my $username = $q->param('username');
$username =~ s/@/./;
my $zone = $q->param('zone');
my $serial = $q->param('serial');
my $refresh = $q->param('refresh');
my $retry = $q->param('retry');
my $expire = $q->param('expire');
my $TTL = $q->param('TTL');

print "\$ORIGIN\ $zone.  ; default zone, note trailing dot\n";
print "\$TTL\ $TTL     ; default time to live set to one hour\n";
print "@     IN SOA $zone. $username. (\n";
print "      $serial       ; serial version of the file (usually a date)\n";
print "      $refresh     ; refresh, slaves refresh after one hour\n";
print "      $retry     ; retry after one hour\n";
print "      $expire  ; Expire after one day\n";
print "      );\n";
print " \n";
if($q->param('loop')) {
        my @recordID = $q->param("recordID");
        my @recordIDin = $q->param("recordIDin");
        my @zonetype = $q->param('zonetype');
        for(my $i=0; $i<=$#recordID; $i++) {
                if ( $zonetype[$i] eq 'A' ) {
                        print "$recordID[$i].        IN A           $recordIDin[$i] ; Authoritative IPv4 Record\n",
                }
                if ( $zonetype[$i] eq 'AAAA' ){
                        print "$recordID[$i].        AAAA           $recordIDin[$i] ; IPv6 Address Record\n",
                }
                if ( $zonetype[$i] eq 'CNAME' ){
                        print "$recordID[$i].        IN CNAME       $recordIDin[$i] ; Cononical alias\n",
                }
                if ( $zonetype[$i] eq 'MX' ){
                        print "$recordID[$i].        MX             $recordIDin[$i] ; Mailserver Record\n",
                }
                if ( $zonetype[$i] eq 'NS' ){
                        print "$recordID[$i].        NS             $recordIDin[$i] ; NS (Name Server) records\n",
                }
        }
}

print <<EOD;
        </pre>
      </td>
    </tr>
 </table>
EOD
print qq(<script type="text/javascript" src="http://www.tradetech.net/javascript.js"></script>\n);
print $q->end_form;
print $q->end_html;
