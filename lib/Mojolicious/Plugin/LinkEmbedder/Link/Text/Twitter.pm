package Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter - twitter.com link

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

Returns the HTML code for an iframe embedding this tweet.

=cut

sub to_embed {
  my $self = shift;
  my $url = Mojo::URL->new('//twitframe.com/?url=' .$self->url);
  my %args = @_;

  $args{width} ||= 550;
  $args{height} ||= 250;

  qq(<iframe frameborder="0" height="$args{height}" width="$args{width}" src="$url"></iframe>);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
