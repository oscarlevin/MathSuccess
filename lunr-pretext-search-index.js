var ptx_lunr_search_style = "textbook";
var ptx_lunr_docs = [
{
  "id": "colophon-1",
  "level": "1",
  "url": "colophon-1.html",
  "type": "Colophon",
  "number": "",
  "title": "Colophon",
  "body": "   example.org   https:\/\/example.org   copyright  "
},
{
  "id": "sec-hidden-curriculum",
  "level": "1",
  "url": "sec-hidden-curriculum.html",
  "type": "Section",
  "number": "1.1",
  "title": "What you are expected to know",
  "body": " What you are expected to know  This is the first paragraph. is a math expression.  "
},
{
  "id": "section-title",
  "level": "1",
  "url": "section-title.html",
  "type": "Section",
  "number": "2.1",
  "title": "Section title",
  "body": " Section title  Hello  "
},
{
  "id": "using-latex",
  "level": "1",
  "url": "using-latex.html",
  "type": "Section",
  "number": "3.1",
  "title": "Using LaTeX",
  "body": " Using LaTeX  In this section we will explore how to use LaTeX to write mathematical documents.  "
},
{
  "id": "colophon-2",
  "level": "1",
  "url": "colophon-2.html",
  "type": "Colophon",
  "number": "",
  "title": "Colophon",
  "body": " This book was authored in PreTeXt .  "
}
]

var ptx_lunr_idx = lunr(function () {
  this.ref('id')
  this.field('title')
  this.field('body')

  ptx_lunr_docs.forEach(function (doc) {
    this.add(doc)
  }, this)
})
