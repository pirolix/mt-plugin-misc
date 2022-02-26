package MT::Plugin::OMV::JapaneseYear;
# $Id$

use strict;
use MT::Template::Context;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.00_02';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://www.kumamotokokufu-h.ed.jp/kumamoto/bungaku/wa_seireki.html',
        description => <<HTMLHEREDOC,
<__trans phrase="Convert the Christian Era to the Japanese one.">
HTMLHEREDOC
});
MT->add_plugin( $plugin );

### Modifier - japanese_year
MT::Template::Context->add_global_filter (japanese_year => sub {
    my ($date, $args) = @_;

    my %date_table = (
#       '元号' => [ YYYY_MM_DD, YYYY_MM_DD ],
        '明治' => [ 1868_09_08, 1912_07_29 ],
        '大正' => [ 1912_07_30, 1926_12_24 ],
        '昭和' => [ 1926_12_25, 1989_01_07 ],
        '平成' => [ 1989_01_08, 2019_04_30 ],
        '令和' => [ 2019_05_01, 2999_12_31 ],
    );

    $date =~ s!(\d{8})!sub {
        my ($datetime) = @_;
        while (my ($name, $table) = each %date_table) {
            if ($table->[0] <= $datetime && $datetime <= $table->[1]) {
                $args = sprintf '%s%d',
                    $name, int ($datetime / 1_00_00) - int ($table->[0] / 1_00_00) + 1;
                $args = Encode::decode ('utf-8', $args) if 5.0 <= $MT::VERSION;;
                last;
            }
        }
        $args;
    }->($1)!e;
    $date;
});

1;