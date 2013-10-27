package Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub - gist.github.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Text>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';

=head1 ATTRIBUTES

=head2 media_id

Not yet decided.

=cut

has media_id => sub { shift->url->path };

=head1 METHODS

=head2 to_embed

Returns the HTML code for a script tag that writes the gist.

=cut

sub to_embed {
  my $self = shift;
  my $url = $self->url;

  unless($url->path =~ /\.js/) {
    $url = $url->clone;
    $url->path($url->path .'.js');
  }

  qq(<script src="$url"></script>);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
