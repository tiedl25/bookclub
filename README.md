# bookclub

This is a simple website to manage a bookclub with data stored in a supabase instance.

Supabase uses a postgresql database under the hood. The database consists of 4 tables: members, books, progress, comments and optional .... 
* members[name, color]
* books[name, author, image_path, from (date), to (date), pages]
* progress[page, rating, book, member, maxPages] -> maxPages can be set, if the book version differs
* comments[text, book, member]

The progress (page, rating, maxPages) and comments can be updated or added from the UI. Members and books must be added from within supabase. The website doesn't have any user management, so everyone can change progress and comments for the other members. This has the benefit of a way simpler website and is reasonable for such a small, clear defined group of people.
