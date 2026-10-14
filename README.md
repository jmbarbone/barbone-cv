# Jordan Mark Barbone's Curriculum Vitae & Resume

This repository contains the source and rendering workflow for both a Curriculum Vitae (CV) and a resume.
The CV is comprehensive and includes full experience, posters, publications, and packages.
The resume is intentionally concise and targeted to a single page.

## References

I maintain a running list of BibTeX references in a separate repository: [jmbarbone/bib-references](https://github.com/jmbarbone/bib-references).
These references are read in, filtered to my work, and then split into CV sections.

## Instructions

A `Makefile` is provided for the common workflows:

- `make`/`make help` prints a short help message
- `make all` runs `setup`, `refresh`, and `render` in sequence
- `make setup` installs the core R/Pandoc dependencies
- `make refresh` updates the package/reference data used by the documents and refreshes the CSL file
- `make render` renders both outputs
- `make cv` renders only the CV
- `make resume` renders only the resume
- `make clean` removes rendered PDFs and `sessioninfo.txt`

## Metadata schema

A single [_metadata.yaml](_metadata.yaml) file stores the descriptive content used by both the CV and resume.
The entries are written in **Markdown** and translated during rendering.

Canonical fields in [_metadata.yaml](_metadata.yaml) are:

```yaml
education:
  - org
  - credential
  - dates
  - location
  - details

experience:
  - org
  - role
  - dates
  - location
  - highlights
  - duties
  - accomplishments

courses:
  - subject
  - org
  - link

awards:
  - credential
  - org
  - dates
  - location
  - details

tutoring:
  - org
  - subject
  - dates
  - location

extracurriculars:
  - org
  - role
  - dates
  - location

skills:
  - name
  - details
```
