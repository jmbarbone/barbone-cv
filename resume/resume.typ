// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

// Auto-generated from YAML sources. Do not edit manually.
#import "typst-template.typ": *

#let cv_given = "Jordan Mark"
#let cv_surname = "Barbone"
#let cv_location = "Philadelphia, PA USA"
#let cv_phone = "+1-202-656-2528"
#let cv_email = "jmbarbone@gmail.com"
#let cv_web = "https://jmbarbone.github.io/"
#let cv_github = "jmbarbone"
#let cv_linkedin = "jmbarbone"

#let experience_data = (
  (
    org: [Cogstate],
    location: [New Haven, CT (Remote)],
    role: [Principal, Data Platform],
    dates: [Sep 2026 - Present],
    bullets: (
      [Created and implemented development standards for Data Engineers and Data Scientists],
      [Architected and implemented a CI/CD process for #strong[Databricks] testing through #strong[GitHub] actions and #strong[Databricks] alerts],
      [Established scalable engineering workflows for analytics delivery and platform reliability],
    ),
  ),
  (
    org: [Cogstate],
    location: [New Haven, CT (Remote)],
    role: [Senior Data Scientist],
    dates: [Oct 2024 - Sep 2026],
    bullets: (
      [Refactored legacy data ingestion processes into #strong[Databricks] centered, #strong[PySpark] coded scheduled jobs with \~70% reduction of time and \~50% reduction in cost; ingestions managing #strong[REST API] responses, and #strong[xlsx]/#strong[csv] files in #strong[SharePoint] with insert, update, and delete history preservation],
      [Developed configuration schemas and validation process centered around #strong[git] to allow broader team input into processes while maintaining data quality],
      [Refactored Statistical Monitoring program in #strong[R] reducing runtimes by \~50% and improving development scaling and unit test coverage],
    ),
  ),
  (
    org: [Cogstate],
    location: [New Haven, CT (Remote)],
    role: [Data Scientist],
    dates: [Jun 2021 - Oct 2024],
    bullets: (
      [Independently developed internal #strong[R packages] to advance programming, visualization, normative data management, central monitoring, data access, and general utilities],
      [Refactored Data Engineering #strong[PySpark] code into a #strong[python] package for data transformations within #strong[Azure Databricks] and #strong[DeltaTable] management],
      [Developed and managed a robust daily and weekly reporting system with #strong[R tidyverse] scripts for the monitoring of a high-profile international Alzheimer's Disease trial],
    ),
  ),
)

#let education_data = (
  (
    org: [West Chester University of Pennsylvania],
    credential: [Master of Arts],
    location: [West Chester, PA],
    dates: [Aug 2017 - May 2019],
  ),
  (
    org: [West Chester University of Pennsylvania],
    credential: [Bachelor of Arts],
    location: [West Chester, PA],
    dates: [Aug 2011 - May 2015],
  ),
)

#let skills_data = (
  (
    name: [R --- Advanced],
    details: [package development, data analysis, statistical programming, data visualization, ETL/data integration, tidyverse, R Markdown, Quarto],
  ),
  (
    name: [Other programming],
    details: [Python (PySpark), SQL, Git, Bash],
  ),
  (
    name: [Clinical trials],
    details: [clinical data management programming, centralized monitoring, eCOA, data review, rater training and qualification],
  ),
  (
    name: [Psychology],
    details: [behavioral statistics, research methods, cognitive psychology, learning psychology],
  ),
)

#let packages_line = [#link("https://jmbarbone.github.io/cnd/")[cnd] | #link("https://github.com/jmbarbone/echo")[echo] | #link("https://jmbarbone.github.io/fuj/")[fuj] | #link("https://CRAN.R-project.org/package=mark")[mark] | #link("https://ycphs.github.io/openxlsx/index.html")[openxlsx] | #link("https://janmarvin.github.io/openxlsx2/")[openxlsx2] | #link("https://jmbarbone.github.io/scribe/")[scribe]]

#render_compact_resume(
  cv_given,
  cv_surname,
  cv_location,
  cv_phone,
  cv_email,
  cv_web,
  cv_github,
  cv_linkedin,
  experience_data,
  education_data,
  skills_data,
  packages_line,
)



