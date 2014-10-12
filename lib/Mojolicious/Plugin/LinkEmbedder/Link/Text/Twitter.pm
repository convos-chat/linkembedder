package Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter - twitter.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Text>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';

=head1 ATTRIBUTES

=head2 media_id

  $str = $self->media_id;

Example C<$str>: "/username/status/123456789".

=cut

has media_id => sub {
  shift->url->path =~ m!^/(\w+/status/\w+)$! ? $1 : '';
};

=head1 METHODS

=head2 to_embed

Returns the HTML code for javascript embedding this tweet.

=cut

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my %args     = @_;

  $args{cards}        ||= 'hidden';
  $args{conversation} ||= 'none';
  $args{lang}         ||= 'en';

  return <<"HTML";
<div class="link-embedder text-twitter">
<blockquote class="twitter-tweet" lang="$args{lang}" data-conversation="$args{conversation}" data-cards="$args{cards}">
<a href="https://twitter.com/$media_id">Loading $media_id...</a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>
HTML
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
