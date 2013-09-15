package Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor - collegehumor.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the the digit from the second path part from L</url>.

=cut

has media_id => sub { shift->url->path->[1] =~ /(\d+)$/ ? $1 : '' };

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self = shift;
  my $src = Mojo::URL->new('http://www.collegehumor.com/moogaloop/moogaloop.swf');
  my %args = @_;

  $src->query({ clip_id => $self->media_id });

  qq(<object><embed src="$src" quality="best" width="400" height="300" type="application/x-shockwave-flash"></embed></object>);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
