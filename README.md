# Jordan Barbone's Curriculum Vitae

I keep a running list of Bibtext references in a separate [GitHub repository](github.com/jmbarbone/bib-references) which I read from using a [custom `read_bib()` function from my person package](https://github.com/jmbarbone/jordan/blob/master/R/read-bib.R) and then filter all the references for my name and save off different types.

This lets me maintain a single master bib text file with all references I'll ever need and manage through [JabRef](https://www.jabref.org/).
The files are saved off with [RefManageR](https://github.com/ropensci/RefManageR) which required me to make some changes to the author names as I prefer `Surname1, Given1 Middle1 and Surname2, Given2` format rather than `Given1 Middle1 Surname1 and Given2 Surname2`

## Instructions


```sh
./render
```
