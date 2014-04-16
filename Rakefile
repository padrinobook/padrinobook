desc "ebook creation"
task :ebook do
  `pandoc -S --epub-metadata=metadata.xml --epub-stylesheet=ebook.css -o padrino_book.epub title.txt *.md`
  puts ".. done\nName of the ebook is `padrino_book.epub`"
end

desc "HTML generation"
task :html do
  `pandoc -o padrino_book.html *.md`
  puts ".. done\nName of the html is `padrino_book.html`"
end

desc "Cleaning the generated output format"
task :clean do
  `rm padrino_book.epub`
  `rm padrino_book.html`
  puts ".. done"
end
