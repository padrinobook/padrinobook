desc "ebook creation"
task :ebook do
  `pandoc -S --epub-metadata=metadata.xml --epub-stylesheet=ebook.css -o padrino_ebook.epub title.txt 01-introduction.md`
end

desc "pdf generation"
task :pdf do
  `markdown2pdf -o padrino_book.pdf 01-introduction.md 02-job-board-application.md `
end

desc "HTML generation"
task :html do
  `pandoc -o padrino_book.html 01-introduction.md 02-job-board-application.md `
end

desc "move output files"
task :move do
  `mv padrino_book.pdf output/`
  `mv padrino_book.html output/`
end
