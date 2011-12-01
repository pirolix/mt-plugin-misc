package MT::Plugin::OMV::Footnote;

use strict;
use MT 4;
use MT::Template::Context;
use MT::Util;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.01';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://www.magicvox.net/archive/2011/01221510/',
        description => <<HTMLHEREDOC,
<__trans phrase="Extend the template tags for footnotes.">
HTMLHEREDOC
});
MT->add_plugin ($plugin);

my $tag     = 'footnote|fn';
my $anchor  = 'footnote-%d';
my $refer   = 'referral-%d';

### Filter - gather_footnote
MT::Template::Context->add_global_filter (gather_footnote => sub {
    my ($text, $format, $ctx) = @_;

    my $footnotes = $ctx->stash ($MYNAME. q{::footnotes}) || [];
    if (ref $format ne 'ARRAY') {
        $format = [ '%s', $format ];
        if (lc $format eq 'reset') {
            $footnotes = [];
            $format = $ctx->stash ($MYNAME. qq{::format})
                or return "$MYNAME: No format";
        }
    }
    $ctx->stash ($MYNAME. qq{::format}, $format);

    $text =~ s!<($tag)>\(?(.*?)\)?</\1>!sub {
        push @$footnotes, $_[0];
        my $index = scalar @$footnotes;
        sprintf $format->[0],
            sprintf qq{<a title="%s" name="$refer" href="#$anchor">$format->[1]</a>},
                MT::Util::encode_html (MT::Util::remove_html($_[0])), $index,$index, $index;
    }->($2)!ge;
    $ctx->stash ($MYNAME. qq{::footnotes}, $footnotes);
    $text;
});

### Conditional Tag - MTIfFootnotes
MT::Template::Context->add_conditional_tag (IfFootnotes => sub {
    my ($ctx, $args, $cond) = @_;

    my $footnotes = $ctx->stash ($MYNAME. qq{::footnotes}) || [];
    scalar @$footnotes;
});

### Block Tag - MTFootnotes
MT::Template::Context->add_container_tag (Footnotes => sub {
    my ($ctx, $args, $cond) = @_;

    my $footnotes = $ctx->stash ($MYNAME. qq{::footnotes}) || [];
    my $out;
    my $count = 0;
    foreach (@$footnotes) {
        $ctx->stash ($MYNAME. qq{::count}, $count + 1);
        $ctx->stash ($MYNAME. qq{::text}, $_);
        $out .= $ctx->slurp ($args, {
            %$cond,
            FootnotesHeader => !$count,
            FootnotesFooter => !defined $footnotes->[$count+1],
        }) or return;
        $count++;
    }
    $out;
});
MT::Template::Context->add_container_tag (FootnotesHeader => \&MT::Template::Context::slurp);
MT::Template::Context->add_container_tag (FootnotesFooter => \&MT::Template::Context::slurp);

### Function Tag - MTFootnoteAnchor/Refer
MT::Template::Context->add_tag (FootnoteAnchor => \&_tag_footnote_anchor);
MT::Template::Context->add_tag (FootnoteRefer => \&_tag_footnote_anchor);
sub _tag_footnote_anchor {
    my ($ctx, $args) = @_;

    my $format = {
        mtfootnoteanchor => $anchor,
        mtfootnoterefer => $refer,
    }->{$ctx->this_tag} or $ctx->error ('Internal error');

    my $count = $ctx->stash ($MYNAME. qq{::count})
        or return $ctx->error ('I need container.');
    sprintf $format, $count;
}

### Function Tag - MTFootnoteCount/Text
MT::Template::Context->add_tag (FootnoteCount => \&_tag_footnote_count);
MT::Template::Context->add_tag (FootnoteText => \&_tag_footnote_count);
sub _tag_footnote_count {
    my ($ctx, $args) = @_;

    my $key = {
        mtfootnotecount => 'count',
        mtfootnotetext => 'text',
    }->{$ctx->this_tag} or $ctx->error ('Internal error');

    my $data = $ctx->stash ($MYNAME. qq{::}. $key);
    return $ctx->error ('I need container.')
        unless defined $data;
    $data;
}

1;