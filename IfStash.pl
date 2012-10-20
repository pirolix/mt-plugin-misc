package MT::Plugin::OMV::IfStash;
# $Id$

use strict;
use MT 3;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.00_01';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    doc_link => 'http://www.magicvox.net/archive/2011/01292201/',
    description => <<HTMLHEREDOC,
<__trans phrase="Allow the conditional template tags which conclude whether the each stash is enable.">
HTMLHEREDOC
});
MT->add_plugin( $plugin );

use MT::Template::Context;
MT::Template::Context->add_conditional_tag ($MYNAME. q{Blog} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Entry} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Entries} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Page} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Pages} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Category} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Folder} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Comment} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Comments} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Commenter} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Ping} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Asset} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Assets} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Template} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Author} => \&_hdlr_conditional_tag);
MT::Template::Context->add_conditional_tag ($MYNAME. q{Results} => \&_hdlr_conditional_tag);

### Conditional tag - IfStash*
sub _hdlr_conditional_tag {
    my ($ctx, $args, $cond) = @_;

    my $tag = lc $ctx->stash('tag');
    my %hash = (
        ifstashblog         => $ctx->stash('blog'),
        ifstashentry        => $ctx->stash('entry'),
        ifstashentries      => $ctx->stash('entries'),
        ifstashpage         => $ctx->stash('entry'),
        ifstashpages        => $ctx->stash('entries'),
        ifstashcategory     => $ctx->stash('category') || $ctx->stash('archive_category'),
        ifstashfolder       => $ctx->stash('category') || $ctx->stash('archive_category'),
        ifstashcomment      => $ctx->stash('comment'),
        ifstashcomments     => $ctx->stash('comments'),
        ifstashcommenter    => $ctx->stash('commenter'),
        ifstashping         => $ctx->stash('ping'),
        ifstashasset        => $ctx->stash('asset'),
        ifstashassets       => $ctx->stash('assets'),
        ifstashtemplate     => $ctx->stash('template'),
        ifstashauthor       => $ctx->stash('author') || $ctx->stash('user'),
        ifstashresults      => $ctx->stash('results'),
    );

    exists $hash{$tag}
        ? $hash{$tag}
        : $ctx->error (MT->translate ('Unknown tag found: [_1]', $tag));
}

1;