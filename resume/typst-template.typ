// Compact CV template source for Quarto Typst rendering

// Guide, ish https://mergersandinquisitions.com/free-investment-banking-resume-template/

#let article(toc_title: none, toc_depth: none, doc) = doc
// #set par(spacing: 1em)

#let colors = (
  primary: luma(20%),
  secondary: luma(45%),
  hyperlink: rgb("#1d4ed8"),
)

#set page(
  paper: "us-letter",
  margin: 0.5in,
  numbering: none,
  footer: none,
)

#let head(
  body,
  size: 9pt,
  weight: 300,
  fill: luma(45%),
) = {
  text(
    font: "Libertinus Serif",
    size: size,
    lang: "en",
    weight: weight,
    fill: fill,
  )[#body]
}

#set text(
  font: "Libertinus Serif",
  size: 9pt,
  lang: "en",
  weight: 300,
)

#set par(justify: false, leading: 0.50em)
#set list(tight: true, marker: [•])

#show link: set text(fill: colors.hyperlink)

#show heading: it => block(sticky: false, it)

#let styled_link(dest, body) = link(
  dest,
  text(fill: colors.hyperlink)[#underline[#body]],
)

#let contact_link(label, dest) = [
  #link(dest)[#text(fill: colors.hyperlink)[#label]]
]

#let section(title, body, sticky: false) = [
  #v(0.62em)
  #block(sticky: sticky)[
    #head(weight: 700, fill: colors.primary)[#upper(title)]
    #v(-1em)
    #line(length: 100%, stroke: 0.45pt + luma(45%))
  ]
  #v(-0.62em)
  #body
]

#let education_entry(role, org, location, dates) = [
  #block(breakable: false)[
    #table(
      columns: (1fr, auto),
      column-gutter: 0.8em,
      row-gutter: 0.4em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#head()[#org]], 
      [#head()[#h(0.2em) #location]],
      [#text(weight: 700)[#emph[#role]]],
      [#text()[#h(0.2em) #dates]],
    )
  ]
]

#let experience_entry(role, org, location, dates, body) = [
  #block(
    sticky: false,
    breakable: false,
  )[
    #table(
      columns: (1fr, auto),
      column-gutter: 0.7em,
      row-gutter: 0.2em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#head()[#org]],
      [#text(fill: luma(45%))[#location]],
      [#head(weight: 700, fill: colors.primary)[#emph[#role]]],
      [#text(fill: colors.primary)[#dates]],
    )
  ]
  #block[
    #v(-0.22em)
    #body
    // #v(0.22em)
  ]
]

#let header(given, surname, location, phone, email, web, github, linkedin) = [
  #set align(center)
  #text[
    #head(size: 15pt)[#given]
    #head(size: 15pt, weight: 700, fill: colors.primary)[#h(0.2em) #surname]
  ]
  #v(0.08em)
  #set text(size: 8.5pt)
  #location #h(0.35em) · #h(0.35em) #link("tel:" + phone)[#phone] #h(0.35em) · #h(0.35em) #link("mailto:" + email)[#email]
  #linebreak()
  #contact_link(web, web)
  #h(0.35em) · #h(0.35em)
  #contact_link("github.com/" + github, "https://github.com/" + github)
  #h(0.35em) · #h(0.35em)
  #contact_link("linkedin.com/in/" + linkedin, "https://www.linkedin.com/in/" + linkedin)
]

#let render_bullets(items) = [
  #for item in items [
    - #item
  ]
]

#let render_experience(experience_data) = [
  #for item in experience_data [
    #experience_entry(item.role, item.org, item.location, item.dates)[
      #render_bullets(item.bullets)
    ]
  ]
]

#let render_education(education_data) = [
  #for item in education_data [
    #education_entry(item.credential, item.org, item.location, item.dates)
  ]
]

#let render_skills(skills_data) = [
  #for item in skills_data [
    #text[
      #head(size: 8pt)[#item.name]
      #text(size: 8pt)[#item.details]
      #v(-0.38em)
    ]
  ]
  #v(0.38em)
]

#let render_compact_resume(
  given,
  surname,
  location,
  phone,
  email,
  web,
  github,
  linkedin,
  experience_data,
  education_data,
  skills_data,
  packages_line,
) = [
  #header(given, surname, location, phone, email, web, github, linkedin)

  #section("Education")[
    #render_education(education_data)
  ]

  #section("Experience")[
    #render_experience(experience_data)
  ]

  #section("Skills")[
    #render_skills(skills_data)
  ]

  #section("R Packages")[
    #packages_line
  ]
]
