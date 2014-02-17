package Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub - gist.github.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Text>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';

=head1 ATTRIBUTES

=head2 media_id

  $str = $self->media_id;

Example C<$str>: "/username/123456789".

=cut

has media_id => sub {
  shift->url->path =~ m!^(/\w+/\w+)(?:\.js)?$! ? $1 : '';
};

=head1 METHODS

=head2 to_embed

Returns the HTML code for a script tag that writes the gist.

=cut

sub to_embed {
  my $self = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;

  qq(<script src="https://gist.github.com$media_id.js"></script>);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
