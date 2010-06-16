CREATE TABLE foo_pages (
    path    VARCHAR(100),
    parent  VARCHAR(100),
    sort    VARCHAR(10),
    title   VARCHAR(100),
    raw     VARCHAR(10000),
    PRIMARY KEY (path),
    FOREIGN KEY (parent) REFERENCES foo_pages (path)
);
