desc "ebook creation"
task :ebook do
  `pandoc -S --epub-metadata=metadata.xml --epub-stylesheet=ebook.css -o padrino_ebook.epub title.txt 01-introduction/01-introduction.md`
end

desc "pdf generation"
task :pdf do
  `markdown2pdf 01-introduction/01-introduction.md`
end

desc "HTML generation"
task :html do
  `pandoc -o padrino.html 01-introduction/01-introduction.md`
end
