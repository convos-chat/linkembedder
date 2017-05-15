package Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';

my $ID = 0;

has media_id => sub {
  shift->url->path =~ m!^(/\w+/\w+)(?:\.js)?$! ? $1 : '';
};

sub provider_name {'Github'}

sub to_embed {
  my $self = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;

  $ID++;

  return $self->tag(
    div => (class => 'link-embedder text-gist-github', id => "link_embedder_text_gist_github_$ID"),
    sub {
      return <<"HERE";
<script>
window.link_embedder_text_gist_github_$ID=function(g){
document.getElementById('link_embedder_text_gist_github_$ID').innerHTML=g.div;
if(window.link_embedder_text_gist_github_styled++)return;
var s=document.createElement('link');s.rel='stylesheet';s.href=g.stylesheet;
document.getElementsByTagName('head')[0].appendChild(s);
};
</script>
<script src="https://gist.github.com$media_id.json?callback=link_embedder_text_gist_github_$ID"></script>
HERE
    },
  );
}

1;
