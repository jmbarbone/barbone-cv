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
  weight: 300,
  fill: luma(45%),
) = {
  text(
    font: "Roboto",
    size: size,
    lang: "en",
    weight: weight,
    fill: fill,
  )[#body]
}

#set text(
  font: "Roboto",
  size: 9pt,
  lang: "en",
  weight: 300,
)

#set par(justify: false, leading: 0.50em)
#set list(tight: true, marker: [•])

// there's a v0.6.2 but I don't feel like writing something to keep this updated
#import "@preview/fontawesome:0.5.0": fa-icon

#show link: set text(fill: hyperlink_text_colour)

#show heading: it => block(sticky: false, it)

#let styled_link(dest, body) = link(
  dest,
  text(fill: hyperlink_text_colour)[#underline[#body]],
)

#let section_icon(title) = {
  if title == "Experience" {
    fa-icon("briefcase", weight: 400)
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

#let header(given, surname, location, phone, email, web, github, linkedin) = [
  #text[
    #head(size: 16.5pt)[#given]
    #head(size: 16.5pt, weight: 700, fill: primary_colour)[#h(0.2em) #surname]
  ]
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
  awards,
  paper_groups_data,
  poster_groups_data,
  packages,
) = [
  #header(given, surname, location, phone, email, web, github, linkedin)

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
#let cv_phone = "+1 202 656 2528"
#let cv_email = "jmbarbone@gmail.com"
#let cv_web = "https://jmbarbone.github.io/"
#let cv_github = "jmbarbone"
#let cv_linkedin = "jmbarbone"

#let experience_data = (
  (
    org: [Cogstate],
    location: [New Haven, CT (Remote)],
    roles: (
      (
        role: [Principal, Data Platform],
        dates: [Sep 2026 - Present],
        bullets: (
          [Created and implemented development standards for Data Engineers and Data Scientists],
          [Provided supervision and training for Data Scientists, Data Engineers, and Data Visualization resources],
          [Architected and implemented a CI/CD process for #strong[Databricks] testing through #strong[GitHub] actions and #strong[Databricks] alerts],
        ),
      ),
      (
        role: [Senior Data Scientist],
        dates: [Oct 2024 - Sep 2026],
        bullets: (
          [Refactored legacy data ingestion processes into #strong[Databricks] centered, #strong[pyspark] coded scheduled jobs with \~70% reduction of time and \~50% reduction in cost; ingestions managing #strong[REST API] responses, and #strong[xlsx]/#strong[csv] files in #strong[SharePoint] with insert, update, and delete history preservation],
          [Developed configuration schemas and validation process centered around #strong[git] to allow broader team input into processes while maintaining data quality],
          [Developed logging and alerting systems in #strong[Databricks] and #strong[SQL] alerts for potential data quality issues to streamline responses to outside team members],
          [Maintained and improved Statistical Monitoring program in #strong[R] for outcome anomaly detection for Clinical Trials],
          [Developed #strong[SQL] queries for Tableau dashboards],
          [Refactored Statistical Monitoring program in #strong[R] reducing runtimes by \~50% and improving development scaling and unit test coverage],
          [Provided supervision and input for Data Scientist, Data Engineer, and Data Visualization resources],
        ),
      ),
      (
        role: [Data Scientist],
        dates: [Jun 2021 - Oct 2024],
        bullets: (
          [Independently developed internal #strong[R packages] to advance programming, visualization, normative data management, central monitoring, data access, and general utilities],
          [Designed and development #strong[R shiny] applications for displaying central monitoring activity and performing interactive analyses],
          [Refactored Data Engineering #strong[PySpark] code into a #strong[python] package for data transformations within #strong[Azure Databricks] and #strong[DeltaTable] management],
          [Refactored legacy #strong[SQL] code to seamlessly integrate #strong[PySpark] functionalities and enforce best coding practices],
          [Designed and implemented an efficient process for managing and updating and tracking normative data, collaborating closely with Science and Product Management teams],
          [Authored comprehensive standards and protocols for #strong[Jira] workflows and #strong[git] management, ensuring consistency and efficiency],
          [Developed and managed a robust daily and weekly reporting system with #strong[R tidyverse] scripts for the monitoring of a high-profile international Alzheimer's Disease trial],
          [Analyzed and interpreted requirements from Science and Data Management to drive strategic advancements within our Data Lakehouse],
          [Developed, reported, and presented analyses with #strong[R tidyverse] scripts for custom data queries related to both ongoing and concluded clinical, providing actionable insights for rater training and central monitoring],
          [Developed a #strong[python] data extraction, reformatting, and storage processes for academic research studies, greatly enhancing accessibility for end-users],
          [Contributed to the creation of poster materials for industry conferences and presentations, showcasing research, developments, and services],
        ),
      ),
    ),
  ),
  (
    org: [Learning Assistance & Resource Center],
    location: [West Chester University of Pennsylvania, West Chester, PA],
    roles: (
      (
        role: [Writing Tutor],
        dates: [Aug 2014 - May 2015],
        bullets: (
          [#strong[Tutored] students in one-on-one or small group sessions to enhance writing skills and promote independent, active learning],
          [Monitored the effectiveness of the Academic Development Program and tracked student progress by maintaining daily activity logs, using #strong[Bloom's Taxonomy], and preparing biweekly student reports and semester evaluations],
        ),
      ),
    ),
  ),
  (
    org: [Madrigal Pharmaceuticals],
    location: [Conshohocken, PA],
    roles: (
      (
        role: [Principal Data Analyst],
        dates: [Dec 2019 - Jun 2021],
        bullets: (
          [Developed internal #strong[R packages] with #strong[tidyverse] features for the creation of daily metric and reports],
          [Aggregated and organized data sources in STDM, ADaM, TFLS, and pre-finalized formats; compiled source data from multiple vendor data bases and reports; reconciled differences between databases using #strong[R tidyverse] suite],
          [Analyzed efficacy, safety, and exploratory data for: ongoing phase 3 studies in NASH and NAFLD; ad hoc analyses for phase 2; biomarker and patient reported outcomes with #strong[R]],
          [Reviewed and reported on statistical testing in #strong[R] such as: ANCOVA, LS-Means, ROC, Kruskal-Wallis, Wilcoxon rank sum, t-test, correlations (Pearson product, Spearman rho, Kendall's tau)],
          [Trained and onboarded data analyst],
        ),
      ),
    ),
  ),
  (
    org: [Signant Health (Bracket)],
    location: [Wayne, PA],
    roles: (
      (
        role: [Clinical Data Specialist],
        dates: [Jan 2018 - Dec 2018],
        bullets: (
          [Analyzed central monitoring data for clinical trials using #strong[R] scripts],
          [Provided analytic support for internal and external research projects, including conference poster preparation],
          [Reviewed audio data from ADAS-Cog, MMSE, and ADCS-ADL administrations; provided feedback on standard administration and scoring, and submitted score change reviews for clinical trial sites],
        ),
      ),
      (
        role: [Clinical Associate],
        dates: [May 2016 - Dec 2017],
        bullets: (
          [Reviewed clinical trial raters' qualifications and recommended standardized training programs.],
          [Developed a training manual in #strong[Microsoft Word] for the standardized administration of ADAS-Cog and MMSE within clinical trials, along with additional training presentations in #strong[Microsoft PowerPoint], ensuring alignment with company standards],
          [Reviewed audio data from ADAS-Cog, MMSE, and ADCS-ADL administrations; provided feedback on standard administration and scoring, and submitted score change reviews for clinical trial sites],
          [Developed new #strong[Excel] trackers for central review tracking for individual central reviewers; compiled reports and presented information for central reviewer management],
        ),
      ),
      (
        role: [Clinical Assistant],
        dates: [Aug 2015 - May 2016],
        bullets: (
          [Reviewed clinical trial raters' qualifications and recommended standardized training programs],
          [Scheduled re-training appointments for clinical trial raters in collaboration with central quality reviewers],
          [Created and maintained study trackers and teleconference schedules in #strong[Excel]],
        ),
      ),
    ),
  ),
  (
    org: [Signant Health (formerly Bracket and CRF Health)],
    location: [Wayne, PA],
    roles: (
      (
        role: [Clinical Data Scientist],
        dates: [Jan 2019 - Nov 2019],
        bullets: (
          [Developed analytic #strong[R] scripts using #strong[tidyverse] features for clinical trial operational and data management monitoring.],
          [Created #strong[R] scripts for processing clinical trial outcome data for risk-based statistical quality monitoring],
          [Provided analytic support for internal and external research projects, including conference poster preparation],
        ),
      ),
    ),
  ),
)

#let education_data = (
  (
    org: [West Chester University of Pennsylvania],
    credential: [Master of Arts],
    location: [West Chester, PA],
    dates: [Aug 2017 - May 2019],
    bullets: (
      [General Psychology, Advisor: Geeta Shivde, Ph.D.],
      [Thesis: The effects of participant-selected background music on executive function task performance],
      [GPA: 4.00],
    ),
  ),
  (
    org: [West Chester University of Pennsylvania],
    credential: [Non-degree Graduate Student],
    location: [West Chester, PA],
    dates: [Aug 2016 - Jun 2017],
    bullets: (
      [Classes in Statistics, Research Methods, and Psychometrics],
      [GPA: 4.00],
    ),
  ),
  (
    org: [West Chester University of Pennsylvania],
    credential: [Bachelor of Arts],
    location: [West Chester, PA],
    dates: [Aug 2011 - May 2015],
    bullets: (
      [Major in Psychology, Minor in Biology],
      [Cumulative GPA: 3.470],
      [Major GPA: 3.834],
    ),
  ),
)

#let awards_items = [
- #strong[Cogstate Values Award] (Dec 2022) --- Cogstate
- #strong[Employee Recognition Award] (Nov 2021) --- Cogstate
- #strong[WCUPA Psychology Service Award] (Apr 2015) --- Psychology Department, West Chester University of Pennsylvania
- #strong[Psychology Research Achievement Award] (Apr 2015) --- Psychology Department, West Chester University of Pennsylvania
- #strong[CRLA Certified Tutor Level II] (Apr 2015) --- Learning Assistance and Resource Center, West Chester University of Pennsylvania
- #strong[Dean's List] (Dec 2014) --- College of Arts and Sciences, West Chester University of Pennsylvania
- #strong[CRLA Certified Tutor Level I] (Dec 2014) --- Learning Assistance and Resource Center, West Chester University of Pennsylvania
- #strong[Dean's List] (May 2013) --- College of Arts and Sciences, West Chester University of Pennsylvania
]

#let paper_groups_data = (
  (
    title: [Peer Reviewed Publications],
    body: [
      - Younossi, Z. M., Stepanova, M., Taub, R. A., #strong[Barbone, J. M.], & Harrison, S. A. (2021). Hepatic fat reduction due to resmetirom in patients with nonalcoholic steatohepatitis is associated with improvement of quality of life. Clinical Gastroenterology and Hepatology. #link("https://doi.org/10.1016/j.cgh.2021.07.039")[doi:10.1016/j.cgh.2021.07.039]
      - Solomon, T. M., #strong[Barbone, J. M.], Feaster, H. T., Miller, D. S., deBros, G. B., Murphy, C. A., & Michalczuk, D. (2019). Comparing the standard and electronic versions of the Alzheimer's disease assessment scale---cognitive subscale: A validation study. The Journal of Prevention of Alzheimer's disease, 6(4), 237--241. #link("https://doi.org/10.14283/jpad.2019.27")[doi:10.14283/jpad.2019.27]
      - Irani, F., #strong[Barbone, J. M.], Beausoleil, J., & Gerald, L. (2017). Is asthma associated with cognitive impairments? A meta-analytic review. Journal of Clinical and Experimental Neuropsychology, 39(10), 965--978. #link("https://doi.org/10.1080/13803395.2017.1288802")[doi:10.1080/13803395.2017.1288802]
    ],
  ),
  (
    title: [Master's Thesis],
    body: [
      - #strong[Barbone, J. M.] (2019). The effects of participant-selected background music on executive function task performance \[Master's thesis, West Chester University of Pennsylvania\]. #link("https://doi.org/10.13140/RG.2.2.34109.41446")[doi:10.13140/RG.2.2.34109.41446]
    ],
  ),
)

#let poster_groups_data = (
  (
    title: [Cogstate - Digital cognition],
    body: [
      - Tronchin, G., Kingery, L., Leventhal, R., Bartolic, E., Wacker, S., #strong[Barbone, J. M.], & Wessels, A. M. (2024, March). Central monitoring of rater performnace and characteristics of efficacy and assessments in the TRAILBLAZER-ALZ 2 study. Poster Presented at the International Conference on Alzheimer's and Parkinson's Disease (ADPD), Lisbon, Portugal, and Online.
      - #strong[Barbone, J. M.], Khurshid, K., Edgar, C. J., & Maruff, P. (2023, July). Equating the ADAS-Cog and MMSE to the Cogstate Brief Battery scores. Poster Presented at the Alzheimer's Association International Conference (AAIC), Amsterdam, Netherlands. #link("https://doi.org/10.1002/alz.077060")[doi:10.1002/alz.077060]
      - Edgar, C. J., Maruff, P., Harrison, J. E., #strong[Barbone, J. M.], Leventhal, R., & Alam, J. j. (2022). Validity and reliability of a composite cognitive outcome measure for clinical trials in dementia with lewy bodies. Poster Presented at the ADPD Conference, Barcelona, Spain. Video: Https:/\/Youtu.be/N8TbGImGV5U. #link("https://www.cogstate.com/wp-content/uploads/2022/04/OO171-Validity-and-reliability-of-a-composite-cognitive-outcome-in-DLB_d273-Read-Only.pdf")
      - Wacker, S., & #strong[Barbone, J. M.] (2022). Rater perspectives on Applied Training of cognitive clinical outcome assessments, delivered by Neuropsychology experts. Poster Presented at AAIC, San Diego, California, USA. #link("https://www.cogstate.com/wp-content/uploads/2022/08/Rater-Perspectives-on-Applied-Training-of-Cognitive-Clinical-Outcome-Assessments.pdf")
      - Edgar, C. J., Amariglio, R., #strong[Barbone, J. M.], Chandler, J., Coons, S., Donohue, M., Lenderking, W., & Sperling, R. (2022, December). Preliminary evidence for reliability and validity of the Interpersonal Functioning and Daily Activities Questionnaire (IFDAQ) in the A4/LEARN pre-randomization sample. Slides Presented at Clincal Trials on Alzheimer's Disease (CTAD) Conference, San Francisco, California, USA.
    ],
  ),
  (
    title: [Cogstate - Cognitive outcomes],
    body: [
      - Edgar, J., Chri, Maruff, P., Harrison, J. E., #strong[Barbone, J. M.], Leventhal, R., & Alam, J. j. (2022). Validity and reliability of a composite cognitive outcome measure for clinical trials in dementia with lewy bodies. Poster Presented at the ADPD Conference, Barcelona, Spain. Video: Https:/\/Youtu.be/N8TbGImGV5U. #link("https://www.cogstate.com/wp-content/uploads/2022/04/OO171-Validity-and-reliability-of-a-composite-cognitive-outcome-in-DLB_d273-Read-Only.pdf")
    ],
  ),
  (
    title: [Madrigal - Liver disease],
    body: [
      - Harrison, S. A., Taub, R., #strong[Barbone, J. M.], Franc, J., & Karsdal, M. A. (2020, March). Resmetirom, a beta selective thyroid hormone receptor agonist, reduces net collagen III deposition in nonalcoholic Steatohepatitis. Poster to Have Been Presented at American Association for the Study of Liver Diseases (AASLD) Emerging Topic Conference 2020, Nuclear Receptors in Nonalcoholic Fatty Liver Diseases (Conference Cancelled).
      - Harrison, S. A., Taub, R. A., Karsdal, M. A., Franc, J., Bashir, M., #strong[Barbone, J. M.], Neff, G., Gunn, N. T., & Moussa, S. (2020, November). Algorithm for predicting advanced NASH fibrosis on screening biopsy in resmetirom phase 3 MAESTRO-NASH clinical trial. Poster Presented at the AASLD Liver Meeting Digit Experience Conference.
      - Younossi, Z. M., Stepanova, M., Taub, R. A., #strong[Barbone, J. M.], Moussa, S., & Harrison, S. A. (2020, November). Improvement of health-related quality of life is associated with improvement of fat fraction by MRI-PDFF in patients with nonalcoholic steatohepatitis treated with resmetirom. Poster Presented at the AASLD Liver Meeting Digit Experience Conference.
    ],
  ),
  (
    title: [Signant Health (Bracket) - eCOA data quality],
    body: [
      - Crittenden, K., Machizawa, S., Feaster, H. T., #strong[Barbone, J. M.], Hong, B., Verma, P., & Zhou, W. (2020, April). Cross-cultural differences in PANSS item ratings: Comparisons of six geo-cultural regions. Poster Presented at the 2020 Schizophrenia International Research Society (SIRS) Conference, Florence, Italy. #link("https://doi.org/10.1093/schbul/sbaa031.103")[doi:10.1093/schbul/sbaa031.103]
      - Roy, M., Brown, J., Hong, B., Benecke, R., Chen-Tackett, Z., Zhou, W., #strong[Barbone, J. M.], Feaster, H. T., & Sachs, G. (2020, September). eCOA prompted MADRS interview: Balancing through assessment and efficiency. Poster Presented at ISCTM.
      - Feaster, H. T., #strong[Barbone, J. M.], Miller, D. S., & Solomon, T. M. (2019, June). Rater remediation on the ADAS-cog leads to longitudinal improvement in clinical trial data quality. Poster Presented at the Alzheimer's Association International Conference (AAIC), Los Angeles, CA, USA. #link("https://doi.org/10.1016/j.jalz.2019.06.3923")[doi:10.1016/j.jalz.2019.06.3923]
      - Karas, S. M., #strong[Barbone, J. M.], Solomon, T. M., Hong, B., & Feaster, H. T. (2019, June). Impact of data quality programs on MMSE inclusion criteria in Alzheimer's disease clinical research trials. Poster Presented at the Alzheimer's Association International Conference (AAIC), Los Angeles, CA, USA. #link("https://doi.org/10.1016/j.jalz.2019.06.862")[doi:10.1016/j.jalz.2019.06.862]
      - Solomon, T. M., Feaster, H. T., Karas, S. M., Garcia-Valdecasas, M., #strong[Barbone, J. M.], DiGregorio, D. T., DeBonis, D., & Miller, D. S. (2019, July). The evolution of technology in data quality programs for Alzheimer's disease clinical trials: What have we learned and where are we going. Poster Presented at the Alzheimer's Association International Conference (AAIC), Los Angeles, CA, USA. #link("https://doi.org/10.1016/j.jalz.2019.06.4332")[doi:10.1016/j.jalz.2019.06.4332]
      - Seichepine, D. R., Solomon, T. M., Jacobs, E. B., #strong[Barbone, J. M.], DiGregorio, D. T., & Miller, D. S. (2018, February). Comparison between "flat" and "enhanced" eCOA of MMSE Attention and Calculation in clinical trials of Alzheimer's disease. Presented at the ISCTM 14th Annual Scientific Meeting, Washington, D.C., USA. #link("https://doi.org/10.13140/RG.2.2.16193.61289")[doi:10.13140/RG.2.2.16193.61289]
      - Solomon, T. M., #strong[Barbone, J. M.], Miller, D. S., & Feaster, H. T. (2018, June). Pilot validation of an Electronic Alzheimer's Disease Assessment Scale - Cognitive Subscale (eADAS-Cog). Poster Presented at the 2018 Alzheimer's Association International Conference, Chicago, IL, USA. #link("https://doi.org/10.1016/j.jalz.2018.06.719")[doi:10.1016/j.jalz.2018.06.719]
      - Feaster, H. T., #strong[Barbone, J. M.], Garcia-Valdecasas-Colell, M., & Solomon, T. M. (2018, July). Electronic ADAS-Cog (eADAS-Cog) data quality: How do countries compare? Poster Presented at the 2018 Alzheimer's Association International Conference, Chicago, IL, USA. #link("https://doi.org/10.1016/j.jalz.2018.06.1373")[doi:10.1016/j.jalz.2018.06.1373]
      - Karas, S. M., #strong[Barbone, J. M.], DeBonis, D., & Solomon, T. M. (2018, July). The use of statistical modeling to complement data quality programs. Poster Presented at the 2018 Alzheimer's Association International Conference, Chicago, IL, USA. #link("https://doi.org/10.1016/j.jalz.2018.06.066")[doi:10.1016/j.jalz.2018.06.066]
      - Solomon, T. M., Karas, S. M., #strong[Barbone, J. M.], DiGregorio, D. T., Miller, D. S., & Feaster, H. T. (2018, July). Analysis of the rates and types of errors on the enhanced eCOA version of the Alzheimer's Disease Assessment Scale - Cognitive subscale and Mini-mental State Examination used in dementia clinical trials. Poster Presented at the 2018 Alzheimer's Association International Conference, Chicago, IL, USA. #link("https://doi.org/10.1016/j.jalz.2018.06.070")[doi:10.1016/j.jalz.2018.06.070]
      - #strong[Barbone, J. M.], Solomon, T. M., Feaster, H. T., Garcia-Valdecasas-Colell, M., & Miller, D. S. (2018, October). MMSE screening data quality for Alzheimer's disease studies across countries. Presented at the 11th Clinical Trials on Alzheimer's Disease (CTAD), Barcelona, Spain. #link("https://doi.org/10.13140/RG.2.2.27921.68966")[doi:10.13140/RG.2.2.27921.68966]
      - Garcia-Valdecasas-Colell, M., #strong[Barbone, J. M.], Solomon, T. M., Feaster, H. T., & Tott, N. (2018, October). Identifying impact of rater change on MMSE and CDR data in multi-national Alzheimer's disease clinical trials. Presented at the 11th Clinical Trials on Alzheimer's Disease (CTAD), Barcelona, Spain. #link("https://doi.org/10.13140/RG.2.2.21210.80327")[doi:10.13140/RG.2.2.21210.80327]
      - Wessels, A. M., #strong[Barbone, J. M.], DiGregorio, D. T., Miller, D. S., Mullen, J. A., Sims, J. R., & Solomon, T. M. (2018, October). Lanabecestat- Rater performance and error characteristics of efficacy assessments in the DAYBREAK-ALZ study. Presented at the 11th Clinical Trials on Alzheimer's Disease (CTAD), Barcelona, Spain. #link("https://bit.ly/32pl8au")
      - Butler, A., Feaster, H. T., Miller, D. S., & #strong[Barbone, J. M.] (2017, May). Using iterative user experience design to improve electronic clinical outcomes assessment data quality. Presented at the ISPOR 22nd Annual International Meeting, Boston, MA, USA. #link("https://bit.ly/3isANeP")
      - Feaster, H. T., Solomon, T. M., Abi-Saab, D., Vogt, A., #strong[Barbone, J. M.], Harrison, J., & Miller, D. S. (2017, July). The impact of electronic clinical outcome assessments (eCOA) on Alzheimer's disease clinical trial data quality. Poster Presented at the Alzheimer's Association International Conference, London, England, UK. #link("https://doi.org/10.1016/j.jalz.2017.06.1828")[doi:10.1016/j.jalz.2017.06.1828]
      - Enger, B., & #strong[Barbone, J. M.] (2017, October). Distribution of performance and incorrect rantings in qualification video scoring. Poster Presented at CNS Summit, Boca Raton, FL, USA. #link("https://doi.org/10.13140/RG.2.2.14096.46088")[doi:10.13140/RG.2.2.14096.46088]
      - Solomon, T. M., #strong[Barbone, J. M.], Karas, S. M., & Feaster, H. T. (2017, October). Longitudinal impact of audio review on data quality. Poster Presented at Clinical Trials on Alzheimer's Disease Conference (CTAD), Boston, MA, USA. #link("https://bit.ly/2DYaFtd")
      - Solomon, T. M., Feaster, H. T., #strong[Barbone, J. M.], & Miller, D. S. (2017, November). Utilizing audio review to improve ADCS-ADL data quality. Poster Presented at Clinical Trials on Alzheimer's Disease Conference (CTAD), Boston, MA, USA. #link("https://bit.ly/3mlKuOc")
    ],
  ),
  (
    title: [WCUPA - Asthma and music cognitive],
    body: [
      - #strong[Barbone, J. M.], & Shivde, G. (2019, May). The effects of participant selected background music on executive task performance. Poster Presented at the Association for Psychological Science, Washington, D.C., USA. #link("https://doi.org/10.13140/RG.2.2.26125.79842")[doi:10.13140/RG.2.2.26125.79842]
      - #strong[Barbone, J. M.] (2018, November). Trends in self-reported use of music while studying: Implications for research. Poster Presented at the Research and Creative Activity Day at West Chester University, West Chester, PA, USA. #link("https://doi.org/10.13140/RG.2.2.14075.57124")[doi:10.13140/RG.2.2.14075.57124]
      - #strong[Barbone, J. M.], Saxena, S., & Irani, F. (2015, February). Neuropsychological performance in individuals with asthma: Two meta-analyses. Poster Presented at the Eastern Psychological Association Conference, Philadelphia, PA, USA. #link("https://bit.ly/3hu6JOi")
      - Mulligan, R. D., #strong[Barbone, J. M.], Saxena, S., Carey-Jr, D., Clappsy, J., & Irani, F. (2015, March). Asthma cognition data collection. Poster Presented at the West Chester University Psychology Research Day, West Chester, PA, USA. #link("https://bit.ly/2ZAD5kn")
      - #strong[Barbone, J. M.], Saxena, S., & Irani, F. (2015, July). Does asthma effect neuropsychological performance? A meta-analysis. Poster Presented at the American Psychological Association Convention, Toronto, Canada.
      - Irani, F., #strong[Barbone, J. M.], & Beausoleil, J. (2015, August). The impact of asthma on cognitive functioning. Paper Presented at the American Psychological Association Convention, Toronto, Canada.
    ],
  ),
)

#let packages_items = [
- #strong[Barbone, J. M.], & Garbuszus, J. M. (2026). openxlsx2: Read, write and edit xlsx files. #link("https://janmarvin.github.io/openxlsx2/")
- Schauberger, P., & Walker, A. (2026). Openxlsx: Read, write and edit xlsx files. #link("https://ycphs.github.io/openxlsx/index.html")
- #strong[Barbone, J. M.] (2025). Cnd: Create and register conditions. #link("https://jmbarbone.github.io/cnd/")
- #strong[Barbone, J. M.] (2025). Fuj: Functions and utilities for jordan. #link("https://jmbarbone.github.io/fuj/")
- #strong[Barbone, J. M.] (2025). Mark: Miscellaneous, analytic r kernels. #link("https://CRAN.R-project.org/package=mark")
- #strong[Barbone, J. M.] (2023). Echo: Echo code evaluations. #link("https://github.com/jmbarbone/echo")
- #strong[Barbone, J. M.] (2023). Scribe: Command argument parsing. #link("https://jmbarbone.github.io/scribe/")
]

#render_compact_cv(
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
  awards_items,
  paper_groups_data,
  poster_groups_data,
  packages_items,
)



