// Compact CV template source for Quarto Typst rendering

#let article(toc_title: none, toc_depth: none, doc) = doc

#let primary_colour = rgb("#3730a3")
#let hyperlink_text_colour = rgb("#1d4ed8")

#set page(
  paper: "us-letter",
  margin: 1in,
)

#let head(
  body,
  size: 10pt,
  weight: 200,
  fill: luma(45%),
) = {
  text(
    font: "Noto Sans",
    size: size,
    lang: "en",
    weight: weight,
    fill: fill,
  )[#body]
}

#set text(
  font: "Noto Sans",
  size: 9pt,
  lang: "en",
)

#set par(justify: false, leading: 0.50em)
#set list(tight: true, marker: [•])

#import "@preview/fontawesome:0.5.0": fa-icon

#show link: set text(fill: hyperlink_text_colour)

#show heading: it => block(sticky: false, it)

#let styled_link(dest, body) = link(
  dest,
  text(fill: hyperlink_text_colour)[#underline[#body]],
)

#let section_icon(title) = {
  if title == "Experience" {
    fa-icon("briefcase")
  } else if title == "Education" {
    fa-icon("graduation-cap")
  } else if title == "Selected Awards" {
    fa-icon("trophy")
  } else if title == "Papers" {
    fa-icon("file-lines")
  } else if title == "Posters" {
    fa-icon("images")
  } else if title == "R Packages" {
    fa-icon("r-project")
  } else {
    fa-icon("circle")
  }
}

#let contact_link(icon_name, label, dest) = [
  #link(dest)[
    #text(fill: hyperlink_text_colour)[#fa-icon(icon_name)]
    #h(0.22em)
    #text(fill: hyperlink_text_colour)[#label]
  ]
]

#let section(title, body, sticky: false) = [
  #block(sticky: sticky)[
    #v(0.48em)
    #head(weight: 700, fill: primary_colour)[
      #section_icon(title)
      #h(0.26em)
      #upper(title)
    ]
    #v(0.06em)
    #line(length: 100%, stroke: 0.55pt + primary_colour)
    #v(0.18em)
  ]
  #body
  // #block[#body]
]

#let subsection(title, body) = [
  #block(sticky: false)[
    #head(weight: 600)[#title]
    #v(0.08em)
  ]
  #block[
    #body
    #v(0.14em)
  ]
]

#let ref_group(title, body) = [
  #block(
    inset: (left: 0.62em),
    stroke: (left: 1.05pt + primary_colour),
    sticky: false,
  )[
    #head()[#title]
    #v(0.10em)
    #body
    #v(0.22em)
  ]
]

#let education_entry(role, org, location, dates, body) = [
  #block(breakable: false)[
    #table(
      columns: (1fr, auto),
      column-gutter: 0.8em,
      row-gutter: 0.2em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#head(size: 9pt)[#org]], [#text(fill: luma(45%))[#fa-icon("calendar-days") #h(0.2em) #dates]],
      [#head(weight: 700, fill: primary_colour)[#role]],
      [#text(fill: primary_colour)[#fa-icon("location-dot") #h(0.2em) #location]],
    )
    #v(0.1em)
    #body
    #v(0.3em)
  ]
]

#let company_group(org, location, body) = [
  #block(
    inset: (left: 0.62em),
    stroke: (left: 1.05pt + primary_colour),
    sticky: false,
    breakable: true,
  )[
    #table(
      columns: (1fr, auto),
      column-gutter: 0.7em,
      row-gutter: 0.1em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#head()[#org]],
      [#text(fill: luma(45%))[#fa-icon("location-dot") #h(0.2em) #location]],
    )
    #v(0.1em)
    #body
    #v(0.3em)
  ]
]

#let role_entry(role, dates, body) = [
  #block(
    sticky: false,
    breakable: false,
  )[
    #table(
      columns: (1fr, auto),
      column-gutter: 0.7em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#head(weight: 700, fill: primary_colour)[#role]],
      [#text(fill: primary_colour)[#fa-icon("calendar-days") #h(0.2em) #dates]],
    )
  ]
  #block[
    #v(0.1em)
    #body
    #v(0.3em)
  ]
]

#let header(name, location, phone, email, web, github, linkedin) = [
  #head(size: 16.5pt, weight: 100)[#strong[#name]]
  #v(0.10em)
  #set text(size: 9pt)
  #text(fill: hyperlink_text_colour)[#fa-icon("house")]
  #h(0.20em)
  #location
  #h(0.20em)
  #text(fill: hyperlink_text_colour)[#fa-icon("phone")]
  #h(0.20em)
  #phone
  #h(0.20em)
  #text(fill: hyperlink_text_colour)[#fa-icon("envelope")]
  #h(0.20em)
  #link("mailto:" + email)[#email]
  #linebreak()
  #contact_link("link", web, web)
  #h(0.20em)
  #contact_link("github", "github.com/" + github, "https://github.com/" + github)
  #h(0.20em)
  #contact_link("linkedin", "linkedin.com/in/" + linkedin, "https://www.linkedin.com/in/" + linkedin)
]

#let render_bullets(items) = [
  #for item in items [
    - #item
  ]
]

#let render_experience(experience_data) = [
  #for group in experience_data [
    #company_group(group.org, group.location)[
      #for role in group.roles [
        #role_entry(role.role, role.dates)[
          #render_bullets(role.bullets)
        ]
      ]
    ]
  ]
]

#let render_education(education_data) = [
  #for item in education_data [
    #education_entry(item.credential, item.org, item.location, item.dates)[
      #render_bullets(item.bullets)
    ]
  ]
]

#let render_reference_groups(groups_data) = [
  #for group in groups_data [
    #ref_group(group.title)[#group.body]
  ]
]

#let render_compact_cv(
  name,
  location,
  phone,
  email,
  web,
  github,
  linkedin,
  experience_data,
  education_data,
  awards,
  paper_groups_data,
  poster_groups_data,
  packages,
) = [
  #header(name, location, phone, email, web, github, linkedin)

  #section("Experience")[
    #render_experience(experience_data)
  ]

  #section("Education")[
    #render_education(education_data)
  ]

  #section("Selected Awards", sticky: true)[
    #block(breakable: false)[#awards]
  ]

  #section("Papers", sticky: true)[
    #render_reference_groups(paper_groups_data)
  ]

  #section("Posters", sticky: true)[
    #render_reference_groups(poster_groups_data)
  ]

  #section("R Packages", sticky: true)[
    #block(breakable: false)[#packages]
  ]
]
