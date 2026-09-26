// Compact CV template source for Quarto Typst rendering

#let article(toc_title: none, toc_depth: none, doc) = doc

#let colors = (
  primary: rgb("#575d7a"), // comet
  secondary: rgb("#3c4058"), // comet-dark
  hyperlink: rgb("#2a87a0"), // ocean-mid
)

#set page(
  paper: "us-letter",
  margin: 0.5in,
  // fill: rgb("#f3f4f6"),
)

#set highlight(
  fill: rgb("#d2b48c"), // desert
)

// text: regular text
// stub: secondary, e.g., company name
// bold: primary, e.g., role
// semi: secondary, e.g., location, dates

#set text(
  font: "Roboto",
  size: 9pt,
  lang: "en",
  weight: 300,
)

#let semi(body) = {
  text(fill: colors.secondary)[#body]
}

#let stub(body) = {
  text(size: 10pt, fill: colors.secondary)[#body]
}

#let bold(body, size: 10pt) = {
  text(size: size, weight: 700, fill: colors.primary)[#body]
}

#show link: it => text(fill: colors.hyperlink)[#underline[#it]]

#show heading: it => block(sticky: true, it)

#let dest(dest, body) = link(dest)[#body]

#set par(justify: false, leading: 0.50em)
#set list(tight: true, marker: [•])

// there's a v0.6.2 but I don't feel like writing something to keep this updated
#import "@preview/fontawesome:0.5.0": fa-icon

#let section_icon(title) = {
  if title == "Experience" {
    fa-icon("briefcase", weight: 400)
  } else if title == "Tutoring" {
    fa-icon("chalkboard-user")
  } else if title == "Education" {
    fa-icon("graduation-cap")
  } else if title == "Skills" {
    fa-icon("screwdriver-wrench")
  } else if title == "Courses" {
    fa-icon("book-open")
  } else if title == "Extracurriculars" {
    fa-icon("people-group")
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
    #text(fill: colors.hyperlink)[#fa-icon(icon_name)]
    #h(0.22em)
    #text(fill: colors.hyperlink)[#label]
  ]
]

#let section(title, body, sticky: false) = [
  #block(sticky: sticky)[
    #v(0.48em)
    #bold[
      #section_icon(title)
      #h(0.26em)
      #upper(title)
    ]
    #v(0.06em)
    #line(length: 100%, stroke: 0.55pt + colors.primary)
    #v(0.18em)
  ]
  #body
]

#let ref_group(title, body) = [
  #block(
    inset: (left: 0.62em),
    stroke: none,
    sticky: true,
  )[
    #stub[#title]
    #v(0.10em)
  ]
  #block(
    inset: (left: 0.62em),
    stroke: (left: 0.7pt + luma(45%)),
  )[
    #body
    #v(0.22em)
  ]
]

#let education_entry(role, org, location, dates, body) = [
  #block(breakable: false)[
    #table(
      columns: (3fr, 2fr),
      column-gutter: 0.9em,
      row-gutter: 0.25em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#stub[#org]],
      [#stub[#fa-icon("location-dot") #h(0.2em) #location]],
      [#bold[#role]],
      [#semi[#fa-icon("calendar-days") #h(0.2em) #dates]],
    )
    #v(0.08em)
    #body
    #v(0.22em)
  ]
]

#let company_group(org, location, body) = [
  #block(
    inset: (left: 0.62em),
    stroke: none,
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
      [#stub[#org]],
      [#stub[#fa-icon("location-dot") #h(0.2em) #location]],
    )
    #v(0.1em)
    #block(
      stroke: (left: 0.7pt + luma(45%)),
      inset: (left: 0.62em),
    )[#body]
    #v(0.3em)
  ]
]

#let role_entry(role, dates, body) = [
  #block(
    sticky: true,
    breakable: false,
  )[
    #table(
      columns: (3fr, 2fr),
      column-gutter: 0.8em,
      inset: 0pt,
      stroke: none,
      align: (left, right),
      [#bold[#role]],
      [#text[#fa-icon("calendar-days") #h(0.2em) #dates]],
    )
  ]
  #block[
    #v(0.08em)
    #body
    #v(0.22em)
  ]
]

#let sep_dot = [#h(0.28em)#text(fill: colors.secondary)[•]#h(0.28em)]

#let header(
  given,
  surname,
  location,
  phone,
  phone_display,
  email,
  web,
  github,
  linkedin,
  professional_title,
  summary_short,
) = [
  #text[
    #text(size: 18pt, weight: 200)[#given]
    #h(0.2em)
    #text(size: 18pt, fill: colors.primary, weight: 900)[#surname]
  ]
  #if professional_title != "" [
    #v(0.02em)
    #text(size: 10pt, fill: colors.secondary, weight: 500)[#professional_title]
  ]
  #v(0.10em)
  #set text(size: 9pt)
  #text(fill: colors.hyperlink)[#fa-icon("house")]
  #h(0.20em)
  #location
  #sep_dot
  #text(fill: colors.hyperlink)[#fa-icon("phone")]
  #h(0.20em)
  #link("tel:" + phone)[#phone_display]
  #sep_dot
  #text(fill: colors.hyperlink)[#fa-icon("envelope")]
  #h(0.20em)
  #link("mailto:" + email)[#email]
  #linebreak()
  #contact_link("link", web, web)
  #sep_dot
  #contact_link("github", "github.com/" + github, "https://github.com/" + github)
  #sep_dot
  #contact_link("linkedin", "linkedin.com/in/" + linkedin, "https://www.linkedin.com/in/" + linkedin)
  #if summary_short != "" [
    #v(0.16em)
    #text(size: 9pt, style: "italic")[#summary_short]
  ]
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

#let render_skills(skills_data) = [
  #for item in skills_data [
    #table(
      columns: (1fr, 3fr),
      column-gutter: 0.8em,
      row-gutter: 0.15em,
      inset: 0pt,
      stroke: none,
      align: (left, left),
      [#stub[#item.name]],
      [#item.details],
    )
    #v(0.08em)
  ]
]

#let render_reference_groups(groups_data) = [
  #for group in groups_data [
    #ref_group(group.title)[#group.body]
  ]
]

#let render_compact_cv(
  given,
  surname,
  location,
  phone,
  phone_display,
  email,
  web,
  github,
  linkedin,
  professional_title,
  summary_short,
  experience_data,
  tutoring,
  education_data,
  skills_data,
  courses,
  extracurriculars,
  awards,
  paper_groups_data,
  poster_groups_data,
  packages,
) = [
  #header(
    given,
    surname,
    location,
    phone,
    phone_display,
    email,
    web,
    github,
    linkedin,
    professional_title,
    summary_short,
  )

  #section("Experience")[
    #render_experience(experience_data)
  ]

  #section("Education")[
    #render_education(education_data)
  ]

  #section("Skills", sticky: true)[
    #block(breakable: false)[#render_skills(skills_data)]
  ]

  #section("Selected Awards", sticky: true)[
    #block(breakable: false)[#awards]
  ]

  #section("Courses", sticky: true)[
    #block(breakable: false)[#courses]
  ]

  #section("Tutoring", sticky: true)[
    #block(breakable: false)[#tutoring]
  ]

  #section("Extracurriculars", sticky: true)[
    #block(breakable: false)[#extracurriculars]
  ]

  #section("R Packages", sticky: true)[
    #block(breakable: false)[#packages]
  ]

  #section("Papers", sticky: true)[
    #render_reference_groups(paper_groups_data)
  ]

  #section("Posters", sticky: true)[
    #render_reference_groups(poster_groups_data)
  ]
]
