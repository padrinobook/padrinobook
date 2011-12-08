# Leanpub Book Formatttt #
This chapter discusses how to format a Leanpub book, and known issues with the current version of Leanpub.

## Code Samples ##
Chapters contain sections, which is where the bulk of your content should be.  A section contains text, and can include images and code samples.

This section will show how a code sample works.  Here is a code sample:


## Planning the application ##

On the following image you can image you can see the basic image of our application[^omnigraffle]:

    $git commit -m

[^omnigraffle]: You can use a classical stencil and paper to create mockups. But my handwriting is
so bad that I used [Omnigraffle](http://www.omnigroup.com/products/omnigraffle/ "Omnigraffle") with
the stencil extensions by [konigi](http://konigi.com/tools/omnigraffle-wireframe-stencils "konigi")
for writing wireframes.


<<(code/sample1.rb)

Here is another sample:

<<[This Code Sample Has A Title](code/sample2.rb)

This text is after the code sample.

## Inserting Images
This section shows how you include an image.

![Leanpub Logo](images/LeanpubLogo1200x610_300ppi.png)

That's it!

We support PNG, JPEG and GIF formats for images.

Note that it's important to get the size and the resolution of the image right:

- You have **4 inches** of width for content in a Leanpub book.
- We use **300 pixels per inch (PPI)** in our books, and we recommend you use that for your images.  Any smaller PPI is scaled up to 300 PPI.  Since we scale up to 300 PPI, your image may look blurry if it's a smaller PPI.
- If you save your image in a 300 PPI format, your image can be up to **1200 pixels wide** (300 PPI * 4 inches = 1200 pixels).
- However, if your save your image in a 72 PPI format (the default in most programs), it can only be 288 pixels wide (72 PPI * 4 inches = 288 pixels).  If it's wider, it will bleed into the right margin, and if your image is much too big it may not show up at all.  (Please don't use 72 PPI though, since scaling looks bad.)

So, in the example above, this image is **1200 pixels wide** x 610 pixels high and it is **300 pixels per inch (PPI)**.  So it fits perfectly in the 4 inches of content.

## Links Become Footnotes
We support Markdown syntax for links, as well as normal HTML links.  Both of these are converted into functioning footnotes in the PDF.  Here's an example of a link to [Leanpub](http://leanpub.com).

## Known Isssues

### Chapters Can't Have Footnotes

A chapter currently can't have footnotes, which means you can't put links in chapters since those get converted into footnotes.  (Yes, we're fixing that!  When it's fixed this document will be updated.)
