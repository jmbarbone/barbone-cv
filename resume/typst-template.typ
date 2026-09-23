// Compact CV template source for Quarto Typst rendering

// Guide, ish https://mergersandinquisitions.com/free-investment-banking-resume-template/

#let article(toc_title: none, toc_depth: none, doc) = doc
// #set par(spacing: 1em)

#let colors = (
  grey: luma(25%),
  hyperlink: rgb("#1d4ed8"),
)

#set page(
  paper: "us-letter",
  margin: 0.5in,
  numbering: none,
  footer: none,
)

#set text(
  font: "Libertinus Serif",
  size: 9pt,
  lang: "en",
  weight: 300,
)

#let semi(body) = text(fill: colors.grey)[#body]
#let head(body) = text(weight: 700)[#emph[#body]]

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
    #text(weight: 700)[#upper(title)]
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
      [#semi[#org]], 
      [#semi[#location]],
      [#head[#role]],
      [#dates],
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
      row-gutter: 0.4em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#semi[#org]],
      [#semi[#location]],
      [#head[#role]],
      [#dates],
    )
  ]
  #block[
    #v(-0.4em)
    #body
  ]
]

#let header(
  given,
  surname,
  location,
  phone,
  email,
  web,
  github,
  linkedin,
) = [
  #set align(center)
  #text[
    #text(size: 15pt, fill: colors.grey)[#given]
    #h(0.2em)
    #text(size: 15pt, weight: 700)[#surname]
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
      #text(fill: colors.grey)[#item.name]
      #item.details
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
