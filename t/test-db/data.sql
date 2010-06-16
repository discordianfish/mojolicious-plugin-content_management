INSERT INTO foo_pages (path, parent, sort, title, raw)
    VALUES ('/foo.html', NULL, '03', 'This is /foo.html', 'Yay');
INSERT INTO foo_pages (path, parent, sort, title, raw)
    VALUES ('/foo/bar.html', '/foo.html', '02', 'This is /foo/bar.html', 'Yay');
INSERT INTO foo_pages (path, parent, sort, title, raw)
    VALUES ('/baz.html', NULL, '01', 'This is /baz.html', 'Yay');
