# Jordan Mark Barbone's Curriculum Vitae & Resume

This repository holds processing for both a Curriculum Vitae (CV) and Resume.
The CV lists all experience, posters, publications, packages, etc, etc.
It's meant to be a long list.
The Resume is kept tight as a single page.

## References

I keep a running list of Bibtext references in a separate [GitHub repository](github.com/jmbarbone/bib-references).
I read this in and then filter for my references.
Those references are broken out into separate sections in my CV.

## Instructions

Three scripts are used:

```sh
./setup
./refresh
./render
```

- `./setup` only needs to be called for a new project
- `./refresh` can be used intermittenly to update packages
- `./render` is used to generate the outputs

## Metadata schema

A single `_metadata.yaml` field holds the fun informative text.
These text are used in both the CV and Resume.
These are written in **markdown**, which is then translated into the outputs.

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
