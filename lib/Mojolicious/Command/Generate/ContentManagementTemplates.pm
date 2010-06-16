package Mojolicious::Command::Generate::ContentManagementTemplates;

use strict;
use warnings;

use base 'Mojo::Command';

__PACKAGE__->attr(description => <<'EOF');
Generate admin templates for the content management plugin.
EOF

__PACKAGE__->attr(usage => <<'EOF');
usage: $0 generate content_management_admin_templates
EOF

sub run {
    my $self = shift;

    $self->renderer->line_start('%%');
    $self->renderer->tag_start('<%%');
    $self->renderer->tag_end('%%>');

    $self->render_to_rel_file('content_management_admin.html.ep',
        'templates/layouts/content_management_admin.html.ep');
    $self->render_to_rel_file('list.html.ep',
        'templates/admin_controller/list.html.ep');
    $self->render_to_rel_file('edit.html.ep',
        'templates/admin_controller/edit.html.ep');
}

!! 42;

__DATA__

@@ content_management_admin.html.ep
<!doctype html>
<html>
<head>
<title>Content Management Admin Interface</title>
<style type="text/css">
html, body {
    margin          : 0;
    padding         : 0;
}
body {
    font-family     : sans-serif;
    font-size       : 15px;
    line-height     : 140%;
    color           : black;
    background-color: #eef;
}
a {
    text-decoration : underline;
    color           : black;
}
#content {
    width           : 700px;
    margin          : 50px auto 0;
    padding         : 0 30px 20px;
    background-color: white;
}
#content hr {
    margin          : 1.5em 0;
    padding         : 0;
    height          : 1px;
    border          : none;
    background-color: #999;
}
#content h1 {
    font-size       : 150%;
    margin          : 0 -30px;
    padding         : 10px 30px;
    background-color: #667;
    color           : white;
}
#content h2 {
    font-size       : 120%;
    margin          : 0 0 1em;
    padding         : 0;
}
#content #navigation {
    margin          : 10px -30px 30px;
    padding         : 10px 15px;
    border-bottom   : 5px solid #ccd;
}
#content #navigation li {
    padding         : 15px;
    display         : inline;
    font-weight     : bold;
}
#content #preview {
    margin          : 20px 0;
    padding         : 20px;
    border          : 2px solid #889;
    background-color: #dde;
}
#preview h1,
#preview h2,
#preview h3,
#preview h4,
#preview h5,
#preview h6 {
    background-color: transparent;
    color           : black;
    margin          : 1.5em 0 .5em;
    padding         : 0;
}
#preview h1 { font-size: 2em; margin-top: 0 }
#preview h2 { font-size: 1.5em }
#preview h3 { font-size: 1.2em }
#preview h4 { font-size: 1em }
#preview h5 { font-size: .9em }
#preview h6 { font-size: .8em }
#content #editform input[type=text],
#content #editform textarea {
    font-family     : sans-serif;
    font-size       : 1em;
    width           : 100%;
    padding         : 0;
}
#content #editform textarea {
    height          : 10em;
}
address {
    width           : 700px;
    margin          : 10px auto 50px;
    padding         : 0 30px;
    text-align      : right;
    font-size       : 80%;
    font-style      : normal;
    color           : #666;
}
</style>
</head>
<body>
    <div id="content">
        <h1>Content Management Admin Interface</h1>
%# Navigation
% my $query = $self->req->url->query->to_string;
% $query = "?$query" if $query;
        <ul id="navigation">
            <li><a href="/admin/<%== $query %>">List all pages</a></li>
% if (stash('page')) {
            <li><a href="<%== stash('page')->path %>">
                Go to <%= stash('page')->path %>
            </a></li>
% }
        </ul>
%== content
    </div>
    <address>
        powered by
        <a href="http://mojolicious.org/">Mojolicious</a>
    </address>
</body>
</html>

@@ list.html.ep
% layout 'content_management_admin';
% my $list; # called recursively
<% $list = {%>
    <% my ($children) = @_; %>
    <ul><% for my $child (@$children) { %>
        <% my $edit_action = 'content_management_admin_edit'; %>
        <% my $url = url_for($edit_action, path => $child->path); %>
        <% my $query = $self->req->url->query->to_string; %>
        <% $query = "?$query" if $query; %>
        <li><a href="<%== "$url$query" %>">
            <%= $child->title %>
        </a>
        <%== $list->($child->children) if @{$child->children} %>
        </li>
    <% } %></ul>
<%}%>
<p>The following pages are available for editing:</p>
<%== $list->(content_list) %>

@@ edit.html.ep
% layout 'content_management_admin';
<h2>Edit: <%= $page->title %></h2>
<form action="" method="post" id="editform">
<% if ($page->title_editable) { %>
<p>
    <label for="title">Title</label>:<br>
    <input type="text" name="title" id="title" value="<%= $page->title %>">
</p>
<% } %>
<textarea name="raw" id="raw"><%= $page->raw %></textarea>
<p>
    <input type="submit" value="Preview!" name="preview_button">
    <input type="submit" value="Update!" name="update_button">
</p>
</form>
<hr>
<p><strong>Preview:</strong></p>
<div id="preview"><%== $page->html %></div>
